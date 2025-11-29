import 'package:flutter_test/flutter_test.dart';

import 'package:tfh2025/models/submission.dart';

void main() {
  group('Submission.initial', () {
    test('投稿直後のドキュメント初期値を設定する', () {
      final before = DateTime.now();

      final submission = Submission.initial(
        id: 'submission123',
        userId: 'user123',
        userName: 'Alice',
        sequenceNumber: 5,
        imageUrl: 'https://example.com/image.png',
        storagePath: 'rooms/room123/image.png',
      );

      final after = DateTime.now();

      expect(submission.id, 'submission123');
      expect(submission.userId, 'user123');
      expect(submission.userName, 'Alice');
      expect(submission.sequenceNumber, 5);
      expect(submission.imageUrl, 'https://example.com/image.png');
      expect(submission.storagePath, 'rooms/room123/image.png');
      expect(
        submission.createdAt.isAfter(before) ||
            submission.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        submission.createdAt.isBefore(after) ||
            submission.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
      expect(submission.status, SubmissionStatus.processing);
      expect(submission.aiResult, isNull);
      expect(submission.validation, isNull);
    });
  });
}
