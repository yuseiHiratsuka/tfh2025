import 'package:flutter_test/flutter_test.dart';

import 'package:tfh2025/models/room.dart';

void main() {
  group('Timestamp converters', () {
    test('TimestampConverter accepts DateTime directly', () {
      final now = DateTime(2025, 1, 1, 12, 0, 0);
      final result = const TimestampConverter().fromJson(now);

      expect(result, now);
    });

    test('NullableTimestampConverter accepts nullable DateTime', () {
      final now = DateTime(2025, 6, 1, 9, 30, 0);
      final result = const NullableTimestampConverter().fromJson(now);
      final nullResult = const NullableTimestampConverter().fromJson(null);

      expect(result, now);
      expect(nullResult, isNull);
    });
  });
}
