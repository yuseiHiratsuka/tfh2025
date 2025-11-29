import * as admin from "firebase-admin";

// Firebase Admin SDKの初期化
admin.initializeApp();
const db = admin.firestore();

const ROOM_ID = "L7qqB8lctYU9niXqOKOT";

async function resetRoom() {
    console.log(`Starting reset for room: ${ROOM_ID}`);

    try {
        // 0. roomドキュメントが存在するか確認
        const roomRef = db.doc(`rooms/${ROOM_ID}`);
        const roomDoc = await roomRef.get();

        if (!roomDoc.exists) {
            console.log(`❌ Room ${ROOM_ID} does not exist in Firestore.`);
            console.log("Please check the room ID and try again.");
            process.exit(1);
        }

        console.log(`✓ Room ${ROOM_ID} found. Current status: ${roomDoc.data()?.status}`);

        // 1. participantsサブコレクションの全ドキュメントを削除
        console.log("Deleting participants subcollection...");
        const participantsSnapshot = await db
            .collection(`rooms/${ROOM_ID}/participants`)
            .get();

        const participantDeletePromises = participantsSnapshot.docs.map((doc) =>
            doc.ref.delete()
        );
        await Promise.all(participantDeletePromises);
        console.log(`Deleted ${participantsSnapshot.size} participants`);

        // 2. submissionsサブコレクションの全ドキュメントを削除
        console.log("Deleting submissions subcollection...");
        const submissionsSnapshot = await db
            .collection(`rooms/${ROOM_ID}/submissions`)
            .get();

        const submissionDeletePromises = submissionsSnapshot.docs.map((doc) =>
            doc.ref.delete()
        );
        await Promise.all(submissionDeletePromises);
        console.log(`Deleted ${submissionsSnapshot.size} submissions`);

        // 3. roomドキュメント自体を更新
        console.log("Updating room document...");
        await roomRef.update({
            chainCount: 0,
            currentCharacter: "ら",
            currentSequence: 0,
            goalReachedBy: "",
            isGoalReached: false,
            readyCount: 0,
            score: 0,
            status: "waiting",
            totalParticipants: 0,
            totalSubmissions: 0,
            usedWords: [], // 配列を空にする
        });

        console.log(`✅ Room ${ROOM_ID} has been successfully reset!`);
        console.log("Reset operations completed:");
        console.log("  - participants subcollection cleared");
        console.log("  - submissions subcollection cleared");
        console.log("  - room fields reset to initial values");

        process.exit(0);
    } catch (error) {
        console.error("❌ Error resetting room:", error);
        process.exit(1);
    }
}

resetRoom();
