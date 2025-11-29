import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

Map<String, dynamic> _participantData({
  required String userId,
  required DateTime joinedAt,
}) {
  return Participant(
    userId: userId,
    displayName: 'user-$userId',
    joinedAt: joinedAt,
    isReady: false,
    isMaster: false,
    isAI: false,
  ).toJson();
}

void main() {
  group('ParticipantRepository.watchParticipants', () {
    const roomId = 'room-id';

    late FakeFirebaseFirestore firestore;
    late ParticipantRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(
          firebaseAuth: MockFirebaseAuth(signedIn: true),
        ),
      );
    });

    test('joinedAt昇順で返し、デコードできないドキュメントはスキップする', () async {
      final roomRef = firestore.collection('rooms').doc(roomId);
      await roomRef.set({'status': 'waiting'});

      final participantsRef = roomRef.collection('participants');
      await participantsRef.doc('late').set(
        _participantData(
          userId: 'late',
          joinedAt: DateTime(2024, 2),
        ),
      );
      await participantsRef.doc('broken').set(
        {
          'userId': 'broken',
          'isReady': false,
          'isMaster': false,
          'isAI': false,
        },
      );
      await participantsRef.doc('early').set(
        _participantData(
          userId: 'early',
          joinedAt: DateTime(2024),
        ),
      );

      final participants = await repository.watchParticipants(roomId).first;
      final userIds = participants.map((participant) => participant.userId).toList();

      expect(userIds, ['early', 'late']);
    });
  });
}
