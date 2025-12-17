import functionsTest = require("firebase-functions-test");

var mockDownload: jest.Mock;
var mockUpdate: jest.Mock;
var mockDoc: jest.Mock;
var mockFile: jest.Mock;
var mockBucket: jest.Mock;
var mockTimestampNow: jest.Mock;

jest.mock("firebase-admin", () => {
    mockDownload = jest.fn();
    mockUpdate = jest.fn();
    mockDoc = jest.fn(() => ({ update: mockUpdate }));
    mockFile = jest.fn(() => ({ download: mockDownload }));
    mockBucket = jest.fn(() => ({ file: mockFile }));
    mockTimestampNow = jest.fn(() => "mock-timestamp");

    const firestoreFn: any = jest.fn(() => ({
        doc: mockDoc,
        Timestamp: { now: mockTimestampNow },
    }));
    firestoreFn.Timestamp = { now: mockTimestampNow };

    return {
        initializeApp: jest.fn(),
        firestore: firestoreFn,
        storage: jest.fn(() => ({ bucket: mockBucket })),
    };
});

var mockGenerateContent: jest.Mock;

jest.mock("@google/generative-ai", () => {
    mockGenerateContent = jest.fn();

    return {
        GoogleGenerativeAI: jest.fn(() => ({
            getGenerativeModel: jest.fn(() => ({
                generateContent: mockGenerateContent,
            })),
        })),
    };
});

jest.mock("@google/genai", () => ({
    GoogleGenAI: jest.fn(() => ({})),
}));

import { processSubmissionImage } from "../index";

const testEnv = functionsTest({ projectId: "demo-test" });

describe("processSubmissionImage", () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    afterAll(() => {
        testEnv.cleanup();
    });

    const callFunction = async (storagePath: string, roomId = "room1", submissionId = "submission1") => {
        const wrapped = testEnv.wrap(processSubmissionImage as any);
        const snapshot = { data: () => ({ storagePath }) };
        await wrapped(
            snapshot,
            { params: { roomId, submissionId } } as any
        );
    };

    it("正常系: StorageからダウンロードしGemini結果でaiResultとstatusが更新される", async () => {
        mockDownload.mockResolvedValue([Buffer.from("fake-image")]);
        mockGenerateContent.mockResolvedValue({
            response: {
                text: () => "  ねこ \n",
            },
        });

        await callFunction("images/sample.jpg", "roomA", "submissionA");

        expect(mockFile).toHaveBeenCalledWith("images/sample.jpg");
        expect(mockDoc).toHaveBeenCalledWith("rooms/roomA/submissions/submissionA");
        expect(mockUpdate).toHaveBeenCalledTimes(1);
        expect(mockUpdate).toHaveBeenCalledWith({
            status: "completed",
            aiResult: {
                word: "ねこ",
                firstChar: "ね",
                lastChar: "こ",
                recognizedAt: "mock-timestamp",
            },
        });
    });

    it("末尾が長音や小文字の単語でもlastCharが直前込みで保存される", async () => {
        mockDownload.mockResolvedValue([Buffer.from("fake-image")]);
        mockGenerateContent.mockResolvedValue({
            response: {
                text: () => "  スパゲッティー ",
            },
        });

        await callFunction("images/long-sound.jpg", "roomB", "submissionB");

        expect(mockUpdate).toHaveBeenCalledTimes(1);
        expect(mockUpdate).toHaveBeenCalledWith({
            status: "completed",
            aiResult: {
                word: "スパゲッティー",
                firstChar: "ス",
                lastChar: "ティ",
                recognizedAt: "mock-timestamp",
            },
        });
    });

    it("Geminiが空文字を返した場合はstatusがfailedになる", async () => {
        mockDownload.mockResolvedValue([Buffer.from("fake-image")]);
        mockGenerateContent.mockResolvedValue({
            response: {
                text: () => "   ",
            },
        });

        await callFunction("images/empty.jpg");

        expect(mockUpdate).toHaveBeenCalledTimes(1);
        expect(mockUpdate).toHaveBeenCalledWith({ status: "failed" });
    });

    it("Gemini呼び出しが例外を投げた場合もstatusがfailedになる", async () => {
        mockDownload.mockResolvedValue([Buffer.from("fake-image")]);
        mockGenerateContent.mockRejectedValue(new Error("Gemini error"));

        await callFunction("images/error.jpg");

        expect(mockUpdate).toHaveBeenCalledTimes(1);
        expect(mockUpdate).toHaveBeenCalledWith({ status: "failed" });
    });
});
