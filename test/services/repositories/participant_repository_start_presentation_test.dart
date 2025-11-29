import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

Map<String, dynamic> _participantData({
  required String userId,
  required bool isMaster,
  bool isReady = false,
}) {
  return Participant(
    userId: userId,
    displayName: 'user-$userId',
    joinedAt: DateTime(2024),
    isReady: isReady,
    isMaster: isMaster,
    isAI: false,
  ).toJson();
}

void main() {
  group('ParticipantRepository.startPresentation', () {
    const roomId = 'room-id';
    const masterId = 'master-user';
    const memberId = 'member-user';

    late FakeFirebaseFirestore firestore;

    ParticipantRepository buildRepository(String userId) {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: userId),
        signedIn: true,
      );
      return ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    test('waiting状態のルームはマスターがpresentingに進め、readyをリセットする', () async {
      final repository = buildRepository(masterId);

      await firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
        'readyCount': 2,
        'totalParticipants': 2,
      });
      final participantsRef =
          firestore.collection('rooms').doc(roomId).collection('participants');
      await participantsRef
          .doc(masterId)
          .set(_participantData(userId: masterId, isMaster: true, isReady: true));
      await participantsRef
          .doc(memberId)
          .set(_participantData(userId: memberId, isMaster: false, isReady: true));

      await repository.startPresentation(roomId: roomId);

      final roomSnap = await firestore.collection('rooms').doc(roomId).get();
      expect(roomSnap.data()?['status'], 'presenting');
      expect(roomSnap.data()?['readyCount'], 0);

      final updatedParticipants = await participantsRef.get();
      for (final doc in updatedParticipants.docs) {
        expect(doc.data()['isReady'], isFalse);
      }
    });

    test('非マスターが開始しようとするとStateErrorになる', () async {
      final repository = buildRepository(memberId);

      await firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
        'readyCount': 1,
        'totalParticipants': 1,
      });
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(memberId)
          .set(_participantData(userId: memberId, isMaster: false, isReady: true));

      await expectLater(
        repository.startPresentation(roomId: roomId),
        throwsA(isA<StateError>()),
      );

      final roomSnap = await firestore.collection('rooms').doc(roomId).get();
      expect(roomSnap.data()?['status'], 'waiting');
    });

    test('waiting以外のステータスでは開始できず、isReadyも変更しない', () async {
      final repository = buildRepository(masterId);

      await firestore.collection('rooms').doc(roomId).set({
        'status': 'playing',
        'readyCount': 0,
        'totalParticipants': 1,
      });
      final participantsRef =
          firestore.collection('rooms').doc(roomId).collection('participants');
      await participantsRef
          .doc(masterId)
          .set(_participantData(userId: masterId, isMaster: true, isReady: true));

      await expectLater(
        repository.startPresentation(roomId: roomId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('ゲームは既に開始されています'),
          ),
        ),
      );

      final roomSnap = await firestore.collection('rooms').doc(roomId).get();
      expect(roomSnap.data()?['status'], 'playing');
      expect(roomSnap.data()?['readyCount'], 0);

      final participantSnap = await participantsRef.doc(masterId).get();
      expect(participantSnap.data()?['isReady'], isTrue);
    });
  });
}
