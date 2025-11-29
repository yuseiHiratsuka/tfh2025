import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";

admin.initializeApp();

const db = admin.firestore();

// Initialize Gemini API
// Note: You need to set the GEMINI_API_KEY environment variable
// firebase functions:secrets:set GEMINI_API_KEY
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

export const processSubmissionImage = functions
    .runWith({
        secrets: ["GEMINI_API_KEY"],
    })
    .firestore
    .document("rooms/{roomId}/submissions/{submissionId}")
    .onCreate(async (snapshot, context) => {
        const data = snapshot.data();
        const { roomId, submissionId } = context.params;

        if (!data) {
            console.error("No data found in snapshot");
            return;
        }

        const { storagePath } = data;

        if (!storagePath) {
            console.error("No storagePath found in submission");
            return;
        }

        try {
            // 1. Download image from Firebase Storage
            const bucket = admin.storage().bucket();
            const file = bucket.file(storagePath);
            const [buffer] = await file.download();

            // Convert buffer to base64
            const imageBase64 = buffer.toString("base64");

            // 2. Call Gemini Vision API
            const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

            const prompt = "この画像をひらがなの単語で表現してください。単語のみを返してください。余計な説明は不要です。";

            const result = await model.generateContent([
                prompt,
                {
                    inlineData: {
                        data: imageBase64,
                        mimeType: "image/jpeg", // Assuming JPEG as per design doc
                    },
                },
            ]);

            const response = await result.response;
            let word = response.text().trim();

            // Clean up the word (remove newlines, spaces, etc.)
            word = word.replace(/[\n\r\s]/g, "");

            // Basic validation/extraction
            if (!word) {
                throw new Error("Gemini returned empty string");
            }

            const firstChar = word.charAt(0);
            const lastChar = word.charAt(word.length - 1);

            // 3. Update Firestore
            await db.doc(`rooms/${roomId}/submissions/${submissionId}`).update({
                status: "completed",
                aiResult: {
                    word: word,
                    firstChar: firstChar,
                    lastChar: lastChar,
                    recognizedAt: admin.firestore.Timestamp.now(),
                },
            });

            console.log(`Successfully processed submission ${submissionId}: ${word}`);

        } catch (error) {
            console.error("Error processing submission:", error);

            await db.doc(`rooms/${roomId}/submissions/${submissionId}`).update({
                status: "failed",
            });
        }
    });

/**
 * しりとり判定ヘルパー関数
 * @param currentChar 現在の文字
 * @param firstChar 提出された単語の最初の文字
 * @param usedWords 使用済み単語のリスト
 * @param word 提出された単語
 * @return {isValid: boolean, reason: string | null}
 */
function validateShiritori(
    currentChar: string,
    firstChar: string,
    usedWords: string[],
    word: string
): { isValid: boolean; reason: string | null } {
    // しりとりチェック: 現在の文字と一致するか
    if (currentChar !== firstChar) {
        return {
            isValid: false,
            reason: `しりとりが成立していません。「${currentChar}」で始まる単語を入力してください。`,
        };
    }

    // 重複チェック: すでに使用された単語でないか
    if (usedWords.includes(word)) {
        return {
            isValid: false,
            reason: "この単語はすでに使用されています。",
        };
    }

    return { isValid: true, reason: null };
}

/**
 * validateAndAdoptSubmission
 * submissionドキュメントが更新された際にトリガーされ、
 * しりとりの判定と採用処理を行う
 */
export const validateAndAdoptSubmission = functions
    .firestore
    .document("rooms/{roomId}/submissions/{submissionId}")
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();
        const { roomId, submissionId } = context.params;

        // 無限ループ防止: validationフィールドが既に存在する場合は処理しない
        if (before.validation || after.validation) {
            console.log(`Validation already exists for submission ${submissionId}, skipping`);
            return;
        }

        // aiResultが設定されていない場合はスキップ
        if (!after.aiResult || !after.aiResult.word) {
            console.log(`aiResult not ready for submission ${submissionId}, skipping`);
            return;
        }

        const { word, firstChar, lastChar } = after.aiResult;
        const { participantId, sequence } = after;

        try {
            // トランザクション処理
            const validationResult = await db.runTransaction(async (transaction) => {
                // 1. roomドキュメント取得
                const roomRef = db.doc(`rooms/${roomId}`);
                const roomDoc = await transaction.get(roomRef);

                if (!roomDoc.exists) {
                    throw new Error(`Room ${roomId} does not exist`);
                }

                const roomData = roomDoc.data()!;
                const {
                    currentSequence,
                    currentCharacter,
                    usedWords = [],
                    chainCount = 0,
                    goalCharacter,
                } = roomData;

                // 2. シーケンス番号チェック
                if (sequence !== currentSequence) {
                    return {
                        isValid: false,
                        isAdopted: false,
                        isGoalReached: false,
                        reason: "シーケンス番号が一致しません。他の参加者の提出が先に採用されました。",
                        adoptionOrder: null,
                    };
                }

                // 3. しりとり判定
                const shiritoriValidation = validateShiritori(
                    currentCharacter,
                    firstChar,
                    usedWords,
                    word
                );

                if (!shiritoriValidation.isValid) {
                    return {
                        isValid: true,
                        isAdopted: false,
                        isGoalReached: false,
                        reason: shiritoriValidation.reason,
                        adoptionOrder: null,
                    };
                }

                // 4. 採用処理
                const newChainCount = chainCount + 1;
                const newUsedWords = [...usedWords, word];

                // 5. ゴール判定（採用後のchainCountが3以上かつlastCharがgoalCharacterと一致）
                const isGoalReached = newChainCount >= 3 && lastChar === goalCharacter;

                // 6. room更新
                const roomUpdate: any = {
                    currentSequence: currentSequence + 1,
                    currentCharacter: lastChar,
                    usedWords: newUsedWords,
                    chainCount: newChainCount,
                };

                // ゴール達成時のスコア計算
                if (isGoalReached) {
                    const score = newChainCount * 100; // 簡単なスコア計算例
                    roomUpdate.status = "completed";
                    roomUpdate.completedAt = admin.firestore.Timestamp.now();
                    roomUpdate.score = score;
                }

                transaction.update(roomRef, roomUpdate);

                // 7. participant更新
                const participantRef = db.doc(`rooms/${roomId}/participants/${participantId}`);
                transaction.update(participantRef, {
                    lastSubmittedAt: admin.firestore.Timestamp.now(),
                });

                return {
                    isValid: true,
                    isAdopted: true,
                    isGoalReached: isGoalReached,
                    reason: null,
                    adoptionOrder: currentSequence + 1,
                };
            });

            // 8. トランザクション終了後にsubmissionドキュメントを更新（無限ループ防止のため別更新）
            await db.doc(`rooms/${roomId}/submissions/${submissionId}`).update({
                validation: {
                    ...validationResult,
                    validatedAt: admin.firestore.Timestamp.now(),
                },
            });

            console.log(`Successfully validated submission ${submissionId}:`, validationResult);

        } catch (error) {
            console.error("Error validating submission:", error);

            // エラー時もvalidationを追加して無限ループを防ぐ
            await db.doc(`rooms/${roomId}/submissions/${submissionId}`).update({
                validation: {
                    isValid: false,
                    isAdopted: false,
                    isGoalReached: false,
                    reason: "検証中にエラーが発生しました。",
                    adoptionOrder: null,
                    validatedAt: admin.firestore.Timestamp.now(),
                },
            });
        }
    });
