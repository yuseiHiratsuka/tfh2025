import * as admin from "firebase-admin";

const PROJECT_ID = "validate-and-adopt-integration";
const FIRESTORE_EMULATOR_HOST =
    process.env.FIRESTORE_EMULATOR_HOST || "127.0.0.1:8080";

process.env.FIRESTORE_EMULATOR_HOST = FIRESTORE_EMULATOR_HOST;
process.env.GCLOUD_PROJECT = PROJECT_ID;
process.env.GOOGLE_CLOUD_PROJECT = PROJECT_ID;
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId: PROJECT_ID });

// eslint-disable-next-line @typescript-eslint/no-var-requires
const functionsTest = require("firebase-functions-test")({
    projectId: PROJECT_ID,
});

const FIRESTORE_EMULATOR_ORIGIN = FIRESTORE_EMULATOR_HOST.includes("://")
    ? FIRESTORE_EMULATOR_HOST
    : `http://${FIRESTORE_EMULATOR_HOST}`;

jest.setTimeout(20000);

describe("validateAndAdoptSubmission (Firestore transaction)", () => {
    let db: FirebaseFirestore.Firestore;
    let wrapped: any;

    const clearFirestore = async () => {
        const response = await fetch(
            `${FIRESTORE_EMULATOR_ORIGIN}/emulator/v1/projects/${PROJECT_ID}/databases/(default)/documents`,
            { method: "DELETE" }
        );

        if (!response.ok) {
            const body = await response.text().catch(() => "");
            throw new Error(
                `Failed to clear Firestore emulator: ${response.status} ${body}`
            );
        }
    };

    const ensureFirestoreEmulatorRunning = async () => {
        try {
            await clearFirestore();
        } catch (error) {
            throw new Error(
                `Firestore emulator is not reachable at ${FIRESTORE_EMULATOR_ORIGIN}. ` +
                `Run "firebase emulators:start --only firestore" or ` +
                `"firebase emulators:exec --only firestore \\"npm test\\"" before executing tests. ` +
                `Original error: ${String(error)}`
            );
        }
    };

    const makeSubmissionChange = (
        path: string,
        before: Record<string, unknown>,
        after: Record<string, unknown>
    ) => {
        const beforeSnap = functionsTest.firestore.makeDocumentSnapshot(
            before,
            path
        );
        const afterSnap = functionsTest.firestore.makeDocumentSnapshot(after, path);
        return functionsTest.makeChange(beforeSnap, afterSnap);
    };

    beforeAll(async () => {
        await ensureFirestoreEmulatorRunning();
        // import after env variables are set
        const functions = require("../src");
        db = admin.firestore();
        wrapped = functionsTest.wrap(functions.validateAndAdoptSubmission);
    });

    afterAll(async () => {
        await clearFirestore();
        functionsTest.cleanup();
    });

    beforeEach(async () => {
        await clearFirestore();
    });

    it("シーケンス不一致なら採用されず、理由付きでvalidationが書き込まれる", async () => {
        const roomId = "room-sequence-mismatch";
        const submissionId = "submission-sequence-mismatch";
        const submissionPath = `rooms/${roomId}/submissions/${submissionId}`;

        await db.doc(`rooms/${roomId}`).set({
            currentSequence: 2,
            currentCharacter: "あ",
            usedWords: ["あめ"],
            chainCount: 1,
            goalCharacter: "い",
            status: "playing",
        });

        await db.doc(submissionPath).set({
            userId: "user-1",
            userName: "テスター",
            sequenceNumber: 1, // currentSequenceとズレ
            aiResult: {
                word: "あさ",
                firstChar: "あ",
                lastChar: "さ",
            },
            validation: null,
        });

        const change = makeSubmissionChange(
            submissionPath,
            {
                userId: "user-1",
                sequenceNumber: 1,
                aiResult: null,
                validation: null,
            },
            {
                userId: "user-1",
                sequenceNumber: 1,
                aiResult: {
                    word: "あさ",
                    firstChar: "あ",
                    lastChar: "さ",
                },
                validation: null,
            }
        );

        await wrapped(change, { params: { roomId, submissionId } });

        const submission = await db.doc(submissionPath).get();
        const validation = submission.data()?.validation;

        expect(validation).toMatchObject({
            isValid: false,
            isAdopted: false,
            isGoalReached: false,
            adoptionOrder: null,
        });
        expect(validation.reason).toContain("シーケンス番号が一致しません");
        expect(validation.validatedAt).toBeInstanceOf(admin.firestore.Timestamp);

        const room = await db.doc(`rooms/${roomId}`).get();
        expect(room.data()).toMatchObject({
            currentSequence: 2,
            currentCharacter: "あ",
            usedWords: ["あめ"],
            chainCount: 1,
        });
    });

    it("しりとり判定NGの場合、reasonCode/reasonがvalidationに反映される", async () => {
        const roomId = "room-shiritori-ng";
        const submissionId = "submission-shiritori-ng";
        const submissionPath = `rooms/${roomId}/submissions/${submissionId}`;

        await db.doc(`rooms/${roomId}`).set({
            currentSequence: 1,
            currentCharacter: "か",
            usedWords: [],
            chainCount: 0,
            goalCharacter: "す",
            status: "playing",
        });

        await db.doc(submissionPath).set({
            userId: "user-2",
            sequenceNumber: 1,
            aiResult: {
                word: "さかな",
                firstChar: "さ", // currentCharacterと不一致
                lastChar: "な",
            },
            validation: null,
        });

        const change = makeSubmissionChange(
            submissionPath,
            {
                userId: "user-2",
                sequenceNumber: 1,
                aiResult: null,
                validation: null,
            },
            {
                userId: "user-2",
                sequenceNumber: 1,
                aiResult: {
                    word: "さかな",
                    firstChar: "さ",
                    lastChar: "な",
                },
                validation: null,
            }
        );

        await wrapped(change, { params: { roomId, submissionId } });

        const submission = await db.doc(submissionPath).get();
        const validation = submission.data()?.validation;

        expect(validation).toMatchObject({
            isValid: false,
            isAdopted: false,
            isGoalReached: false,
            reasonCode: "start_char_mismatch",
        });
        expect(validation.reason).toContain("「か」から始まる絵を描いてください");

        const room = await db.doc(`rooms/${roomId}`).get();
        expect(room.data()).toMatchObject({
            currentSequence: 1,
            currentCharacter: "か",
            usedWords: [],
            chainCount: 0,
        });
    });

    it("採用成功時にroom更新とvalidation書き込み、ゴール達成の反映まで行う", async () => {
        const roomId = "room-success";
        const submissionId = "submission-success";
        const submissionPath = `rooms/${roomId}/submissions/${submissionId}`;
        const startedAt = admin.firestore.Timestamp.fromMillis(Date.now() - 5000);

        await db.doc(`rooms/${roomId}`).set({
            currentSequence: 2,
            currentCharacter: "か",
            usedWords: ["からす", "すもう"],
            chainCount: 2,
            goalCharacter: "す",
            status: "playing",
            startedAt,
            timeLimit: 300,
        });

        await db.doc(submissionPath).set({
            userId: "user-success",
            sequenceNumber: 2,
            aiResult: {
                word: "かす",
                firstChar: "か",
                lastChar: "す",
            },
            validation: null,
        });

        const change = makeSubmissionChange(
            submissionPath,
            {
                userId: "user-success",
                sequenceNumber: 2,
                aiResult: null,
                validation: null,
            },
            {
                userId: "user-success",
                sequenceNumber: 2,
                aiResult: {
                    word: "かす",
                    firstChar: "か",
                    lastChar: "す",
                },
                validation: null,
            }
        );

        await wrapped(change, { params: { roomId, submissionId } });

        const room = await db.doc(`rooms/${roomId}`).get();
        const roomData = room.data();

        expect(roomData).toMatchObject({
            currentSequence: 3,
            currentCharacter: "す",
            chainCount: 3,
            status: "success",
            isGoalReached: true,
            goalReachedBy: "user-success",
        });
        expect(roomData?.usedWords).toEqual(["からす", "すもう", "かす"]);
        expect(roomData?.chainBonus).toBe(3000);
        expect(roomData?.timeBonus).toBeGreaterThan(0);
        expect(roomData?.score).toBe(roomData!.chainBonus + roomData!.timeBonus);
        expect(roomData?.finishedAt).toBeInstanceOf(admin.firestore.Timestamp);

        const submission = await db.doc(submissionPath).get();
        const validation = submission.data()?.validation;

        expect(validation).toMatchObject({
            isValid: true,
            isAdopted: true,
            isGoalReached: true,
            adoptionOrder: 3,
        });
        expect(validation.validatedAt).toBeInstanceOf(admin.firestore.Timestamp);
    });

    it("roomが存在しなくてもvalidationがエラー状態で埋まる", async () => {
        const roomId = "room-missing";
        const submissionId = "submission-room-missing";
        const submissionPath = `rooms/${roomId}/submissions/${submissionId}`;

        await db.doc(submissionPath).set({
            userId: "user-3",
            sequenceNumber: 1,
            aiResult: {
                word: "あめ",
                firstChar: "あ",
                lastChar: "め",
            },
            validation: null,
        });

        const change = makeSubmissionChange(
            submissionPath,
            {
                userId: "user-3",
                sequenceNumber: 1,
                aiResult: null,
                validation: null,
            },
            {
                userId: "user-3",
                sequenceNumber: 1,
                aiResult: {
                    word: "あめ",
                    firstChar: "あ",
                    lastChar: "め",
                },
                validation: null,
            }
        );

        await wrapped(change, { params: { roomId, submissionId } });

        const submission = await db.doc(submissionPath).get();
        const validation = submission.data()?.validation;

        expect(validation).toMatchObject({
            isValid: false,
            isAdopted: false,
            isGoalReached: false,
            reason: "検証中にエラーが発生しました。",
            adoptionOrder: null,
        });
        expect(validation.validatedAt).toBeInstanceOf(admin.firestore.Timestamp);
    });
});
