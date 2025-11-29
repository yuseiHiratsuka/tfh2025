import functionsTest = require("firebase-functions-test");

jest.mock("firebase-admin", () => {
    const docStore = new Map<string, any>();
    let collectionDocCounter = 0;

    const docSetCalls: Array<{ path: string; data: any }> = [];
    const collectionSetCalls: Array<{ path: string; data: any; id: string }> = [];

    const docMock = jest.fn((path: string) => {
        const getMock = jest.fn(async () => ({
            exists: docStore.has(path),
            data: () => docStore.get(path),
        }));

        const setMock = jest.fn(async (data: any) => {
            docStore.set(path, data);
            docSetCalls.push({ path, data });
        });

        return { path, get: getMock, set: setMock };
    });

    const collectionMock = jest.fn((path: string) => ({
        path,
        doc: jest.fn((id?: string) => {
            const docId = id ?? `generated-id-${++collectionDocCounter}`;
            const docPath = `${path}/${docId}`;

            const setMock = jest.fn(async (data: any) => {
                docStore.set(docPath, data);
                collectionSetCalls.push({ path: docPath, data, id: docId });
            });

            return { id: docId, path: docPath, set: setMock };
        }),
    }));

    const fakeTimestamp = { seconds: 1700000000, nanoseconds: 0 };
    const timestampNowMock = jest.fn(() => fakeTimestamp);

    const fileSaveMock = jest.fn().mockResolvedValue(undefined);
    const fileMakePublicMock = jest.fn().mockResolvedValue(undefined);
    const fileMock = jest.fn((storagePath: string) => ({
        path: storagePath,
        save: fileSaveMock,
        makePublic: fileMakePublicMock,
    }));

    const bucketMock = jest.fn(() => ({
        name: "mock-bucket",
        file: fileMock,
    }));

    const storageMock = jest.fn(() => ({
        bucket: bucketMock,
    }));

    const decodeValue = (value: any): any => {
        if (value === null || value === undefined) return value;
        if ("stringValue" in value) return value.stringValue;
        if ("booleanValue" in value) return value.booleanValue;
        if ("integerValue" in value) return Number(value.integerValue);
        if ("doubleValue" in value) return value.doubleValue;
        if (value.arrayValue && Array.isArray(value.arrayValue.values)) {
            return value.arrayValue.values.map((entry: any) => decodeValue(entry));
        }
        if (value.mapValue && value.mapValue.fields) {
            return decodeFields(value.mapValue.fields);
        }
        return null;
    };

    const decodeFields = (fields: Record<string, any> = {}) => {
        const result: Record<string, any> = {};
        Object.entries(fields).forEach(([key, fieldValue]) => {
            result[key] = decodeValue(fieldValue);
        });
        return result;
    };

    const snapshotMock = jest.fn((proto: any) => {
        const fields = typeof proto === "string" ? undefined : proto.fields;
        return {
            data: () => (fields ? decodeFields(fields) : undefined),
            ref: { path: typeof proto === "string" ? "" : proto.name || "" },
        };
    });

    const firestoreInstance = {
        doc: docMock,
        collection: collectionMock,
        snapshot_: snapshotMock,
    };

    const firestoreMock = Object.assign(jest.fn(() => firestoreInstance), {
        Timestamp: { now: timestampNowMock },
    });

    const reset = () => {
        docStore.clear();
        docSetCalls.length = 0;
        collectionSetCalls.length = 0;
        collectionDocCounter = 0;
        docMock.mockClear();
        collectionMock.mockClear();
        fileSaveMock.mockClear();
        fileMakePublicMock.mockClear();
        fileMock.mockClear();
        bucketMock.mockClear();
        storageMock.mockClear();
        snapshotMock.mockClear();
        (firestoreMock as jest.Mock).mockClear();
        timestampNowMock.mockClear();
    };

    return {
        __esModule: true,
        initializeApp: jest.fn(),
        firestore: firestoreMock as any,
        storage: storageMock,
        __mocked: {
            docStore,
            docSetCalls,
            collectionSetCalls,
            docMock,
            collectionMock,
            bucketMock,
            fileMock,
            fileSaveMock,
            fileMakePublicMock,
            timestampNowMock,
            snapshotMock,
            reset,
        },
    };
});

jest.mock("@google/generative-ai", () => {
    const generateContentMock = jest.fn().mockResolvedValue({
        response: { text: jest.fn(() => "  たこ \n") },
    });

    const getGenerativeModelMock = jest.fn(() => ({
        generateContent: generateContentMock,
    }));

    return {
        __esModule: true,
        GoogleGenerativeAI: jest.fn().mockImplementation(() => ({
            getGenerativeModel: getGenerativeModelMock,
        })),
        __mocked: {
            generateContentMock,
            getGenerativeModelMock,
        },
    };
});

jest.mock("@google/genai", () => {
    const generatedImageBuffer = Buffer.from("mock-image-bytes");

    const generateImageContentMock = jest.fn().mockResolvedValue({
        candidates: [
            {
                content: {
                    parts: [
                        {
                            inlineData: {
                                data: generatedImageBuffer.toString("base64"),
                            },
                        },
                    ],
                },
            },
        ],
    });

    return {
        __esModule: true,
        GoogleGenAI: jest.fn().mockImplementation(() => ({
            models: {
                generateContent: generateImageContentMock,
            },
        })),
        __mocked: {
            generateImageContentMock,
            generatedImageBuffer,
        },
    };
});

import { triggerAISubmission } from "../src";

type RoomData = {
    status: string;
    chainCount: number;
    currentSequence: number;
    currentCharacter: string;
    usedWords: string[];
    goalCharacter: string;
    isGoalReached: boolean;
};

type AdminMockModule = typeof import("firebase-admin") & {
    __mocked: {
        docStore: Map<string, any>;
        docSetCalls: Array<{ path: string; data: any }>;
        collectionSetCalls: Array<{ path: string; data: any; id: string }>;
        docMock: jest.Mock;
        collectionMock: jest.Mock;
        bucketMock: jest.Mock;
        fileMock: jest.Mock;
        fileSaveMock: jest.Mock;
        fileMakePublicMock: jest.Mock;
        timestampNowMock: jest.Mock;
        snapshotMock: jest.Mock;
        reset: () => void;
    };
};

type GenAIMockModule = {
    __mocked: {
        generateContentMock: jest.Mock;
        getGenerativeModelMock: jest.Mock;
    };
};

type GenAIImageMockModule = {
    __mocked: {
        generateImageContentMock: jest.Mock;
        generatedImageBuffer: Buffer;
    };
};

const adminMock = jest.requireMock("firebase-admin") as AdminMockModule;
const genAIMock = jest.requireMock("@google/generative-ai") as GenAIMockModule;
const genAIImageMock = jest.requireMock("@google/genai") as GenAIImageMockModule;

describe("triggerAISubmission", () => {
    const fft = functionsTest();
    const wrapped = fft.wrap(triggerAISubmission);

    const baseRoom: RoomData = {
        status: "playing",
        chainCount: 1,
        currentSequence: 3,
        currentCharacter: "か",
        usedWords: ["かめ"],
        goalCharacter: "み",
        isGoalReached: false,
    };

    const makeChange = (roomId: string, beforeData: RoomData, afterData: RoomData) => {
        const beforeSnap = fft.firestore.makeDocumentSnapshot(beforeData, `rooms/${roomId}`);
        const afterSnap = fft.firestore.makeDocumentSnapshot(afterData, `rooms/${roomId}`);
        return fft.makeChange(beforeSnap, afterSnap);
    };

    beforeEach(() => {
        adminMock.__mocked.reset();
        jest.clearAllMocks();
    });

    afterAll(() => {
        fft.cleanup();
    });

    describe("スキップ条件", () => {
        const roomId = "room-skip";

        const skipCases: Array<{ name: string; before: RoomData; after: RoomData }> = [
            {
                name: "statusがplaying以外",
                before: { ...baseRoom, status: "waiting" },
                after: { ...baseRoom, status: "waiting", chainCount: 2 },
            },
            {
                name: "chainCount未更新",
                before: baseRoom,
                after: baseRoom,
            },
            {
                name: "AIターンでない",
                before: baseRoom,
                after: { ...baseRoom, chainCount: 3 },
            },
            {
                name: "ゴール済み",
                before: baseRoom,
                after: { ...baseRoom, chainCount: 2, isGoalReached: true },
            },
        ];

        it.each(skipCases)("$name", async ({ before, after }) => {
            const change = makeChange(roomId, before, after);
            await wrapped(change, { params: { roomId } });

            expect(genAIMock.__mocked.generateContentMock).not.toHaveBeenCalled();
            expect(genAIImageMock.__mocked.generateImageContentMock).not.toHaveBeenCalled();
            expect(adminMock.__mocked.docSetCalls).toHaveLength(0);
            expect(adminMock.__mocked.collectionSetCalls).toHaveLength(0);
            expect(adminMock.__mocked.fileSaveMock).not.toHaveBeenCalled();
            expect(adminMock.__mocked.fileMakePublicMock).not.toHaveBeenCalled();
        });
    });

    it("AIターン時にAI参加者とsubmissionを作成し、Storageへ保存する", async () => {
        const roomId = "room-ai";
        const beforeData: RoomData = { ...baseRoom };
        const afterData: RoomData = { ...baseRoom, chainCount: 2 };
        const change = makeChange(roomId, beforeData, afterData);

        const fakeNow = 1_700_000_000_000;
        const dateSpy = jest.spyOn(Date, "now").mockReturnValue(fakeNow);

        await wrapped(change, { params: { roomId } });
        dateSpy.mockRestore();

        expect(genAIMock.__mocked.getGenerativeModelMock).toHaveBeenCalledWith({ model: "gemini-2.5-flash" });
        expect(genAIMock.__mocked.generateContentMock).toHaveBeenCalledTimes(1);
        expect(genAIImageMock.__mocked.generateImageContentMock).toHaveBeenCalledTimes(1);
        expect(adminMock.__mocked.bucketMock).toHaveBeenCalled();

        const aiParticipantSet = adminMock.__mocked.docSetCalls.find((call) =>
            call.path.endsWith("/participants/ai_participant")
        );
        expect(aiParticipantSet).toBeDefined();
        expect(aiParticipantSet?.data).toMatchObject({
            userId: "ai_participant",
            displayName: "AI しりとりくん",
            isAI: true,
        });

        const submissionCall = adminMock.__mocked.collectionSetCalls[0];
        const expectedStoragePath = `rooms/${roomId}/submissions/ai_participant_${fakeNow}.png`;
        const expectedImageUrl = `https://storage.googleapis.com/mock-bucket/${expectedStoragePath}`;

        expect(submissionCall).toBeDefined();
        expect(submissionCall.data.id).toBe(submissionCall.id);
        expect(submissionCall.data).toMatchObject({
            userId: "ai_participant",
            sequenceNumber: afterData.currentSequence,
            storagePath: expectedStoragePath,
            imageUrl: expectedImageUrl,
            status: "processing",
        });

        expect(adminMock.__mocked.fileMock).toHaveBeenCalledWith(expectedStoragePath);
        expect(adminMock.__mocked.fileSaveMock).toHaveBeenCalledWith(
            genAIImageMock.__mocked.generatedImageBuffer,
            { metadata: { contentType: "image/png" } }
        );
        expect(adminMock.__mocked.fileMakePublicMock).toHaveBeenCalled();

        const imagePrompt = genAIImageMock.__mocked.generateImageContentMock.mock.calls[0][0].contents;
        expect(typeof imagePrompt).toBe("string");
        expect(imagePrompt).toContain("たこ");
    });
});
