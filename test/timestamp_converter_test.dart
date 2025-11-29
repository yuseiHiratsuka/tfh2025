import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tfh2025/models/room.dart';

void main() {
  group('TimestampConverter', () {
    const converter = TimestampConverter();

    test('accepts DateTime directly', () {
      final now = DateTime(2025, 1, 1, 12, 0, 0);
      final result = converter.fromJson(now);

      expect(result, now);
    });

    test('converts Timestamp to DateTime', () {
      final source = DateTime.utc(2024, 12, 31, 23, 59, 59);
      final result = converter.fromJson(Timestamp.fromDate(source));

      expect(result.isAtSameMomentAs(source), isTrue);
    });

    test('converts epoch milliseconds to DateTime', () {
      final source = DateTime.utc(2024, 5, 10, 12, 30, 0);
      final result = converter.fromJson(source.millisecondsSinceEpoch);

      expect(result.isAtSameMomentAs(source), isTrue);
    });

    test('converts ISO8601 string to DateTime', () {
      const iso = '2024-05-10T15:30:00.000Z';
      final result = converter.fromJson(iso);

      expect(result.isAtSameMomentAs(DateTime.parse(iso)), isTrue);
    });

    test('throws ArgumentError for invalid type', () {
      expect(() => converter.fromJson(3.14), throwsArgumentError);
    });
  });

  group('NullableTimestampConverter', () {
    const converter = NullableTimestampConverter();

    test('accepts nullable DateTime', () {
      final now = DateTime(2025, 6, 1, 9, 30, 0);
      final result = converter.fromJson(now);
      final nullResult = converter.fromJson(null);

      expect(result, now);
      expect(nullResult, isNull);
    });

    test('converts Timestamp, int, and string inputs', () {
      final source = DateTime.utc(2024, 7, 1, 8, 0, 0);

      final timestampResult = converter.fromJson(Timestamp.fromDate(source))!;
      final millisResult = converter.fromJson(source.millisecondsSinceEpoch)!;
      final stringResult = converter.fromJson(source.toIso8601String())!;

      expect(timestampResult.isAtSameMomentAs(source), isTrue);
      expect(millisResult.isAtSameMomentAs(source), isTrue);
      expect(stringResult.isAtSameMomentAs(source), isTrue);
    });

    test('throws ArgumentError for invalid type', () {
      expect(() => converter.fromJson(3.14), throwsArgumentError);
    });
  });
}
