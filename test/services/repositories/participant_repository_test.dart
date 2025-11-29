import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

void main() {
  group('ParticipantRepository.joinRoom', () {
    const roomId = 'room-id';
    const userId = 'user-id';

    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late ParticipantRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: userId),
        signedIn: true,
      );
      repository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
    });

    test('最初の参加者はisMasterになりtotalParticipantsが1増える', () async {
      await firestore.collection('rooms').doc(roomId).set({
        'totalParticipants': 0,
      });

      final participant = await repository.joinRoom(
        roomId: roomId,
        displayName: 'first-user',
      );

      expect(participant.userId, userId);
      expect(participant.isMaster, isTrue);

      final savedParticipant = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .get();
      expect(savedParticipant.exists, isTrue);
      expect(savedParticipant.data()?['isMaster'], isTrue);

      final room = await firestore.collection('rooms').doc(roomId).get();
      expect(room.data()?['totalParticipants'], 1);
    });

    test('既存参加者の再参加ではtotalParticipantsを増やさない', () async {
      const initialCount = 2;
      await firestore.collection('rooms').doc(roomId).set({
        'totalParticipants': initialCount,
      });

      final existingParticipant = Participant(
        userId: userId,
        displayName: 'existing-user',
        joinedAt: DateTime(2024, 1, 1),
        isReady: false,
        isMaster: true,
        isAI: false,
      );
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .set(existingParticipant.toJson());

      final participant = await repository.joinRoom(
        roomId: roomId,
        displayName: 'new-name',
      );

      final room = await firestore.collection('rooms').doc(roomId).get();
      expect(room.data()?['totalParticipants'], initialCount);
      expect(participant, existingParticipant);
    });

    test('存在しないroomIdではStateErrorを返す', () async {
      await expectLater(
        repository.joinRoom(
          roomId: roomId,
          displayName: 'any',
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(roomId),
          ),
        ),
      );
    });
  });

  group('ParticipantRepository.setReadyStatus', () {
    const roomId = 'room-id';
    const userId = 'user-id';

    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late ParticipantRepository repository;

    Future<void> _createParticipant({required bool isReady}) {
      return firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .set({
        'userId': userId,
        'displayName': 'user',
        'joinedAt': DateTime(2024, 1, 1),
        'isReady': isReady,
        'isMaster': false,
        'isAI': false,
      });
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(
        mockUser: MockUser(uid: userId),
        signedIn: true,
      );
      repository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
    });

    test('isReadyのトグルでreadyCountが±1される', () async {
      await firestore.collection('rooms').doc(roomId).set({
        'readyCount': 0,
        'totalParticipants': 2,
        'status': 'waiting',
      });
      await _createParticipant(isReady: false);

      await repository.setReadyStatus(roomId: roomId, isReady: true);

      final afterReadyRoom =
          await firestore.collection('rooms').doc(roomId).get();
      final afterReadyParticipant = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .get();

      expect(afterReadyRoom.data()?['readyCount'], 1);
      expect(afterReadyParticipant.data()?['isReady'], isTrue);

      await repository.setReadyStatus(roomId: roomId, isReady: false);

      final afterCancelRoom =
          await firestore.collection('rooms').doc(roomId).get();
      final afterCancelParticipant = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .get();

      expect(afterCancelRoom.data()?['readyCount'], 0);
      expect(afterCancelParticipant.data()?['isReady'], isFalse);
    });

    test('同じ状態で呼ぶとreadyCountや更新時刻を変更せずに早期リターンする', () async {
      final initialUpdatedAt = DateTime(2024, 2, 1);
      await firestore.collection('rooms').doc(roomId).set({
        'readyCount': 1,
        'totalParticipants': 2,
        'status': 'waiting',
        'updatedAt': initialUpdatedAt,
      });
      await _createParticipant(isReady: true);

      await repository.setReadyStatus(roomId: roomId, isReady: true);

      final room = await firestore.collection('rooms').doc(roomId).get();
      final participant = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .get();

      expect(room.data()?['readyCount'], 1);
      final updatedAtValue = room.data()?['updatedAt'];
      final updatedAt = updatedAtValue is Timestamp
          ? updatedAtValue.toDate()
          : updatedAtValue as DateTime?;
      expect(updatedAt, initialUpdatedAt);
      expect(participant.data()?['isReady'], isTrue);
    });

    test('presenting中に全員準備完了するとplayingに遷移する', () async {
      await firestore.collection('rooms').doc(roomId).set({
        'readyCount': 1,
        'totalParticipants': 2,
        'status': 'presenting',
      });
      await _createParticipant(isReady: false);

      await repository.setReadyStatus(roomId: roomId, isReady: true);

      final room = await firestore.collection('rooms').doc(roomId).get();
      final participant = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .get();

      expect(room.data()?['status'], 'playing');
      expect(room.data()?['readyCount'], 2);
      expect(room.data()?['startedAt'], isNotNull);
      expect(participant.data()?['isReady'], isTrue);
    });
  });
}
