import 'package:freezed_annotation/freezed_annotation.dart';

import 'room.dart';

part 'ai_result.freezed.dart';
part 'ai_result.g.dart';

/// AI認識結果
@freezed
abstract class AIResult with _$AIResult {
  const factory AIResult({
    /// 認識された単語（ひらがな）
    required String word,

    /// 最初の文字（ひらがな1文字）
    required String firstChar,

    /// 最後の文字（ひらがな1文字）
    required String lastChar,

    /// 認識完了日時
    @TimestampConverter() required DateTime recognizedAt,
  }) = _AIResult;

  const AIResult._();

  factory AIResult.fromJson(Map<String, dynamic> json) =>
      _$AIResultFromJson(json);
}
