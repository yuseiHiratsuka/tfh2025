import 'package:flutter_test/flutter_test.dart';

import 'package:tfh2025/models/participant.dart';

void main() {
  group('Participant.initial', () {
    test('参加時のドキュメント初期値を設定する', () {
      final before = DateTime.now();

      final participant = Participant.initial(
        userId: 'user123',
        displayName: 'Alice',
        avatarUrl: 'https://example.com/avatar.png',
      );

      final after = DateTime.now();

      expect(participant.userId, 'user123');
      expect(participant.displayName, 'Alice');
      expect(participant.avatarUrl, 'https://example.com/avatar.png');
      expect(
        participant.joinedAt.isAfter(before) ||
            participant.joinedAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        participant.joinedAt.isBefore(after) ||
            participant.joinedAt.isAtSameMomentAs(after),
        isTrue,
      );
      expect(participant.isReady, isFalse);
      expect(participant.isMaster, isFalse);
      expect(participant.isAI, isFalse);
      expect(participant.lastSubmittedAt, isNull);
    });

    test('マスターやAI指定を反映する', () {
      final participant = Participant.initial(
        userId: 'master1',
        displayName: 'Master',
        isMaster: true,
        isAI: true,
      );

      expect(participant.isMaster, isTrue);
      expect(participant.isAI, isTrue);
    });
  });
}
