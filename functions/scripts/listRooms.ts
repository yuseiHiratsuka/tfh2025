import * as admin from "firebase-admin";

// Firebase Admin SDKの初期化
admin.initializeApp();
const db = admin.firestore();

async function listRooms() {
    console.log("Fetching all rooms from Firestore...\n");

    try {
        const roomsSnapshot = await db.collection("rooms").get();

        if (roomsSnapshot.empty) {
            console.log("❌ No rooms found in Firestore.");
            process.exit(0);
        }

        console.log(`✓ Found ${roomsSnapshot.size} room(s):\n`);

        for (const doc of roomsSnapshot.docs) {
            const data = doc.data();
            console.log(`📍 Room ID: ${doc.id}`);
            console.log(`   Status: ${data.status || "N/A"}`);
            console.log(`   Chain Count: ${data.chainCount || 0}`);
            console.log(`   Current Character: ${data.currentCharacter || "N/A"}`);
            console.log(`   Current Sequence: ${data.currentSequence || 0}`);
            console.log(`   Goal Character: ${data.goalCharacter || "N/A"}`);
            console.log(`   Is Goal Reached: ${data.isGoalReached || false}`);
            console.log(`   Total Participants: ${data.totalParticipants || 0}`);
            console.log(`   Total Submissions: ${data.totalSubmissions || 0}`);
            console.log(`   Used Words: ${data.usedWords?.length || 0} words`);

            // サブコレクションの件数も確認
            const participantsSnapshot = await db
                .collection(`rooms/${doc.id}/participants`)
                .get();
            const submissionsSnapshot = await db
                .collection(`rooms/${doc.id}/submissions`)
                .get();

            console.log(`   Participants (subcollection): ${participantsSnapshot.size}`);
            console.log(`   Submissions (subcollection): ${submissionsSnapshot.size}`);
            console.log("");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error fetching rooms:", error);
        process.exit(1);
    }
}

listRooms();
