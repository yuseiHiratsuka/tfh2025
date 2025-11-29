import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/ai_result.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/models/submission.dart';
import 'package:tfh2025/models/validation.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';

class MockDataSeeder {
  MockDataSeeder(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> seedMockData(String roomId) async {
    debugPrint('[MockDataSeeder] Seeding data for room: $roomId');
    
    final now = DateTime.now();
    final roomRef = _firestore.collection('rooms').doc(roomId);

    // ルームデータ作成
    final room = Room.initial(
      id: roomId,
      startCharacter: 'みゃくみゃく',
      goalCharacter: 'きつねうどん',
      timeLimit: 120,
    ).copyWith(
      status: RoomStatus.success,
      score: 8500,
      chainCount: 4,
      startedAt: now.subtract(const Duration(minutes: 2)),
      finishedAt: now,
      totalParticipants: 2,
      totalSubmissions: 2,
    );

    await roomRef.set(room.toJson());

    // 参加者データ作成
    final participants = [
      Participant.initial(
        userId: 'user1',
        displayName: 'パイナップル',
        avatarUrl: null,
      ).copyWith(joinedAt: now.subtract(const Duration(minutes: 3))),
      Participant.initial(
        userId: 'user2',
        displayName: 'サル',
        avatarUrl: null,
      ).copyWith(joinedAt: now.subtract(const Duration(minutes: 3))),
    ];

    final batch = _firestore.batch();

    for (final p in participants) {
      batch.set(
        roomRef.collection('participants').doc(p.userId),
        p.toJson(),
      );
    }

    // 投稿データ作成
    final submissions = [
      Submission.initial(
        id: 'sub1',
        userId: 'user1',
        userName: 'パイナップル',
        sequenceNumber: 0,
        imageUrl: 'https://placehold.co/600x600/png?text=Shoes', // ダミー画像URL
        storagePath: 'dummy/path/1',
      ).copyWith(
        status: SubmissionStatus.completed,
        aiResult: AIResult(
          word: 'くつ',
          firstChar: 'く',
          lastChar: 'つ',
          recognizedAt: now.subtract(const Duration(seconds: 100)),
        ),
        validation: Validation(
          isValid: true,
          isAdopted: true,
          isGoalReached: false,
          validatedAt: now.subtract(const Duration(seconds: 98)),
        ),
      ),
      Submission.initial(
        id: 'sub2',
        userId: 'user2',
        userName: 'サル',
        sequenceNumber: 1,
        imageUrl: 'https://placehold.co/600x600/png?text=Bird', // ダミー画像URL
        storagePath: 'dummy/path/2',
      ).copyWith(
        status: SubmissionStatus.completed,
        aiResult: AIResult(
          word: 'つばめ',
          firstChar: 'つ',
          lastChar: 'め',
          recognizedAt: now.subtract(const Duration(seconds: 60)),
        ),
        validation: Validation(
          isValid: true,
          isAdopted: true,
          isGoalReached: false,
          validatedAt: now.subtract(const Duration(seconds: 58)),
        ),
      ),
       Submission.initial(
        id: 'sub3',
        userId: 'user1',
        userName: 'パイナップル',
        sequenceNumber: 2,
        imageUrl: 'https://placehold.co/600x600/png?text=Glasses', // ダミー画像URL
        storagePath: 'dummy/path/3',
      ).copyWith(
        status: SubmissionStatus.completed,
        aiResult: AIResult(
          word: 'めがね',
          firstChar: 'め',
          lastChar: 'ね',
          recognizedAt: now.subtract(const Duration(seconds: 40)),
        ),
        validation: Validation(
          isValid: true,
          isAdopted: true,
          isGoalReached: false,
          validatedAt: now.subtract(const Duration(seconds: 38)),
        ),
      ),
      Submission.initial(
        id: 'sub4',
        userId: 'user2',
        userName: 'サル',
        sequenceNumber: 3,
        imageUrl: 'https://placehold.co/600x600/png?text=Noodle', // ダミー画像URL
        storagePath: 'dummy/path/4',
      ).copyWith(
        status: SubmissionStatus.completed,
        aiResult: AIResult(
          word: 'ねぎうどん',
          firstChar: 'ね',
          lastChar: 'ん',
          recognizedAt: now.subtract(const Duration(seconds: 10)),
        ),
        validation: Validation(
          isValid: true,
          isAdopted: true,
          isGoalReached: true,
          validatedAt: now.subtract(const Duration(seconds: 8)),
        ),
      ),
    ];

    for (final s in submissions) {
      batch.set(
        roomRef.collection('submissions').doc(s.id),
        s.toJson(),
      );
    }

    await batch.commit();
    debugPrint('[MockDataSeeder] Seeding completed');
  }
}

final mockDataSeederProvider = Provider<MockDataSeeder>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return MockDataSeeder(firestore);
});

