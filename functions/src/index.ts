import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { GoogleGenAI } from "@google/genai";
import { shouldAISubmit, validateShiritori } from "./shiritori";

admin.initializeApp();

const db = admin.firestore();

// Initialize Gemini API
// Note: You need to set the GEMINI_API_KEY environment variable
// firebase functions:secrets:set GEMINI_API_KEY
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");
const genAIImage = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY || "" });

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
        const { userId, sequenceNumber } = after;

        try {
            // トランザクション処理
            const validationResult = await db.runTransaction(async (transaction) => {
                // 1. 全ての読み取りを最初に実行
                const roomRef = db.doc(`rooms/${roomId}`);
                const participantRef = db.doc(`rooms/${roomId}/participants/${userId}`);

                const roomDoc = await transaction.get(roomRef);
                const participantDoc = await transaction.get(participantRef);

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
                if (sequenceNumber !== currentSequence) {
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
                    lastChar,
                    usedWords,
                    word,
                    chainCount,
                    goalCharacter
                );

                if (!shiritoriValidation.isValid) {
                    return {
                        isValid: false,
                        isAdopted: false,
                        isGoalReached: false,
                        reasonCode: shiritoriValidation.reasonCode,
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
                    const now = admin.firestore.Timestamp.now();

                    // 残り時間の計算
                    let remainingTime = 0;
                    if (roomData.startedAt && roomData.timeLimit) {
                        const elapsedSeconds = now.seconds - roomData.startedAt.seconds;
                        remainingTime = Math.max(0, roomData.timeLimit - elapsedSeconds);
                    }

                    // スコア計算: 残り時間(秒数) x 50点 + 絵が繋がった回数 x 1000点
                    const timeBonus = remainingTime * 50;
                    const chainBonus = newChainCount * 1000;
                    const totalScore = timeBonus + chainBonus;

                    roomUpdate.status = "success";
                    roomUpdate.isGoalReached = true;
                    roomUpdate.goalReachedBy = userId;
                    roomUpdate.finishedAt = now;
                    roomUpdate.score = totalScore;
                    roomUpdate.timeBonus = timeBonus;
                    roomUpdate.chainBonus = chainBonus;
                    roomUpdate.remainingTime = remainingTime;
                }

                transaction.update(roomRef, roomUpdate);

                // 7. participant更新（存在する場合のみ）
                if (participantDoc.exists) {
                    transaction.update(participantRef, {
                        lastSubmittedAt: admin.firestore.Timestamp.now(),
                    });
                }

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

/**
 * Nano Banana (Gemini 2.5 Flash Image) を使って画像を生成する
 * @param word 生成する単語
 * @returns 画像のバイナリデータ
 */
async function generateSimpleImage(word: string): Promise<Buffer> {
    const prompt = `「${word}」を表すシンプルな白黒イラスト。一筆書き風。背景は白。文字は含まないこと`;

    const response = await genAIImage.models.generateContent({
        model: "gemini-2.5-flash-image",
        contents: prompt,
    });

    // 画像データを取得
    if (!response.candidates || response.candidates.length === 0) {
        throw new Error("No candidates returned from Gemini");
    }

    const candidate = response.candidates[0];
    if (!candidate || !candidate.content || !candidate.content.parts) {
        throw new Error("Invalid response structure from Gemini");
    }

    for (const part of candidate.content.parts) {
        if (part.inlineData && part.inlineData.data) {
            return Buffer.from(part.inlineData.data, "base64");
        }
    }

    throw new Error("No image generated from Gemini");
}

/**
 * AI参加者が画像を生成・投稿する
 */
export const triggerAISubmission = functions
    .runWith({
        secrets: ["GEMINI_API_KEY"],
        memory: "1GB",
        timeoutSeconds: 120,
    })
    .firestore
    .document("rooms/{roomId}")
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();
        const { roomId } = context.params;

        // ゲームが進行中でない場合はスキップ
        if (after.status !== "playing") {
            console.log(`Room ${roomId} is not playing (status: ${after.status})`);
            return;
        }

        // chainCountが更新されていない場合はスキップ
        if (before.chainCount === after.chainCount) {
            return;
        }

        // AI投稿のタイミングかチェック
        if (!shouldAISubmit(after.chainCount)) {
            console.log(`Not AI turn for room ${roomId}, chainCount: ${after.chainCount}`);
            return;
        }

        // ゴール到達している場合はスキップ
        if (after.isGoalReached) {
            console.log(`Goal already reached for room ${roomId}`);
            return;
        }

        console.log(`AI submission triggered for room ${roomId}, chainCount: ${after.chainCount}`);

        try {
            const currentCharacter = after.currentCharacter;
            const usedWords = after.usedWords || [];
            const goalCharacter = after.goalCharacter;

            // AI参加者のドキュメントが存在しない場合は作成
            const aiParticipantRef = db.doc(`rooms/${roomId}/participants/ai_participant`);
            const aiParticipantDoc = await aiParticipantRef.get();

            if (!aiParticipantDoc.exists) {
                await aiParticipantRef.set({
                    userId: "ai_participant",
                    displayName: "AI しりとりくん",
                    avatarUrl: null,
                    joinedAt: admin.firestore.Timestamp.now(),
                    lastSubmittedAt: null,
                    isReady: true,
                    isMaster: false,
                    isAI: true,
                });
                console.log(`Created AI participant for room ${roomId}`);
            }

            // 1. 適切な単語を生成 (Gemini Text API)
            const textModel = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

            const wordPrompt = `
「${currentCharacter}」で始まる、しりとりに使える簡単な日本語の単語を1つだけ答えてください。
以下の単語は既に使われているので避けてください: ${usedWords.join(", ")}
単語のみをひらがなで返してください。説明は不要です。
「ん」で終わる単語は避けてください。
${goalCharacter ? `できるだけ「${goalCharacter}」で終わる単語は避けてください。` : ""}
`;

            const wordResult = await textModel.generateContent(wordPrompt);
            const wordResponse = await wordResult.response;
            let targetWord = wordResponse.text().trim().replace(/[\n\r\s]/g, "");

            console.log(`AI generated word: ${targetWord} for room ${roomId}`);

            // 2. 画像を生成（Nano Banana）
            const imageBuffer = await generateSimpleImage(targetWord);

            // 3. Storage に保存
            const timestamp = Date.now();
            const storagePath = `rooms/${roomId}/submissions/ai_participant_${timestamp}.png`;
            const bucket = admin.storage().bucket();
            const file = bucket.file(storagePath);

            await file.save(imageBuffer, {
                metadata: {
                    contentType: "image/png",
                },
            });

            await file.makePublic();
            const imageUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;

            console.log(`AI image saved to ${storagePath}`);

            // 4. Submission ドキュメント作成
            const submissionRef = db.collection(`rooms/${roomId}/submissions`).doc();
            await submissionRef.set({
                id: submissionRef.id,
                userId: "ai_participant",
                userName: "AI しりとりくん",
                createdAt: admin.firestore.Timestamp.now(),
                sequenceNumber: after.currentSequence,
                imageUrl: imageUrl,
                storagePath: storagePath,
                status: "processing",
                aiResult: null,
                validation: null,
            });

            console.log(`AI submission created: ${submissionRef.id} for room ${roomId}`);

        } catch (error) {
            console.error("Error in AI submission:", error);
            // エラーが発生してもゲームは継続
        }
    });
