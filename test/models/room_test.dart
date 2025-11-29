import 'package:flutter_test/flutter_test.dart';

import 'package:tfh2025/models/room.dart';

void main() {
  group('Room.initial', () {
    test('ドキュメント仕様の初期値を設定する', () {
      final room = Room.initial(
        id: 'room123',
        startCharacter: 'a',
        goalCharacter: 'z',
      );

      expect(room.id, 'room123');
      expect(room.status, RoomStatus.waiting);
      expect(room.createdAt, room.updatedAt);
      expect(room.startCharacter, 'a');
      expect(room.goalCharacter, 'z');
      expect(room.maxPlayers, 10);
      expect(room.timeLimit, 120);
      expect(room.currentCharacter, 'a');
      expect(room.currentSequence, 0);
      expect(room.usedWords, isEmpty);
      expect(room.chainCount, 0);
      expect(room.isGoalReached, isFalse);
      expect(room.totalSubmissions, 0);
      expect(room.totalParticipants, 0);
      expect(room.readyCount, 0);
      expect(room.failureReason, isNull);
      expect(room.startedAt, isNull);
      expect(room.goalReachedBy, isNull);
      expect(room.finishedAt, isNull);
      expect(room.score, isNull);
      expect(room.timeBonus, isNull);
      expect(room.chainBonus, isNull);
    });
  });
}
