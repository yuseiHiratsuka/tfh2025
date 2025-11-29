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
            const model = genAI.getGenerativeModel({ model: "gemini-pro-vision" });

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
