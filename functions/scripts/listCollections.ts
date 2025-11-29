import * as admin from "firebase-admin";

// Firebase Admin SDKの初期化
admin.initializeApp();
const db = admin.firestore();

async function listCollections() {
    console.log("Fetching all collections from Firestore...\n");

    try {
        const collections = await db.listCollections();

        if (collections.length === 0) {
            console.log("❌ No collections found in Firestore.");
            process.exit(0);
        }

        console.log(`✓ Found ${collections.length} collection(s):\n`);

        for (const collection of collections) {
            console.log(`📁 Collection: ${collection.id}`);

            const snapshot = await collection.limit(5).get();
            console.log(`   Documents: ${snapshot.size} (showing first 5)`);

            if (!snapshot.empty) {
                snapshot.docs.forEach((doc, index) => {
                    console.log(`   [${index + 1}] Document ID: ${doc.id}`);
                    const data = doc.data();
                    const keys = Object.keys(data).slice(0, 5);
                    console.log(`       Fields: ${keys.join(", ")}${Object.keys(data).length > 5 ? ", ..." : ""}`);
                });
            }

            console.log("");
        }

        process.exit(0);
    } catch (error) {
        console.error("❌ Error fetching collections:", error);
        process.exit(1);
    }
}

listCollections();
