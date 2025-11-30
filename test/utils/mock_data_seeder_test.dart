import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfh2025/utils/mock_data_seeder.dart';

void main() {
  group('MockDataSeeder', () {
    test('seedMockDataでルーム・参加者・投稿が投入される', () async {
      final firestore = FakeFirebaseFirestore();
      final seeder = MockDataSeeder(firestore);

      const roomId = 'room-123';
      await seeder.seedMockData(roomId);

      final roomDoc = await firestore.collection('rooms').doc(roomId).get();
      expect(roomDoc.exists, isTrue);

      final roomData = roomDoc.data()!;
      expect(roomData['status'], 'success');
      expect(roomData['startCharacter'], 'みゃくみゃく');
      expect(roomData['goalCharacter'], 'きつねうどん');
      expect(roomData['score'], 8500);
      expect(roomData['chainCount'], 4);
      expect(roomData['totalParticipants'], 2);
      expect(roomData['totalSubmissions'], 4);
      expect(roomData['startedAt'], isA<Timestamp>());
      expect(roomData['finishedAt'], isA<Timestamp>());

      final participantsSnap =
          await roomDoc.reference.collection('participants').get();
      expect(participantsSnap.docs.length, 2);
      expect(
        participantsSnap.docs.map((doc) => doc.id).toSet(),
        {'user1', 'user2'},
      );

      final submissionsSnap = await roomDoc.reference
          .collection('submissions')
          .orderBy('sequenceNumber')
          .get();
      expect(submissionsSnap.docs.length, 4);

      final lastSubmission = submissionsSnap.docs.last.data();
      expect(lastSubmission['status'], 'completed');
      final validation = lastSubmission['validation'] as Map<String, dynamic>;
      expect(validation['isGoalReached'], isTrue);
      expect(validation['isAdopted'], isTrue);
      final aiResult = lastSubmission['aiResult'] as Map<String, dynamic>;
      expect(aiResult['word'], 'ねぎうどん');
      expect(aiResult['recognizedAt'], isA<Timestamp>());
    });
  });
}
