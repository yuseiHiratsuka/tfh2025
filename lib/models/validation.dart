import 'package:freezed_annotation/freezed_annotation.dart';

import 'room.dart';

part 'validation.freezed.dart';
part 'validation.g.dart';

/// 不採用/不正解理由のコード
enum ReasonCode {
  /// 開始文字が一致しない
  @JsonValue('start_char_mismatch')
  startCharMismatch,

  /// 「ん」で終わる単語
  @JsonValue('ends_with_n')
  endsWithN,

  /// 過去に使用された単語
  @JsonValue('word_duplicated')
  wordDuplicated,

  /// 最低ターン数に達していない
  @JsonValue('min_turns_not_reached')
  minTurnsNotReached,

  /// 既に次のお題に進んでいる
  @JsonValue('already_advanced')
  alreadyAdvanced,
}

/// 検証結果
@freezed
abstract class Validation with _$Validation {
  const factory Validation({
    /// しりとりとして正しいか
    required bool isValid,

    /// 採用されたか
    required bool isAdopted,

    /// ゴール到達か
    required bool isGoalReached,

    /// 検証完了日時
    @TimestampConverter() required DateTime validatedAt,

    /// 不採用/不正解理由のコード値
    ReasonCode? reasonCode,

    /// 不採用/不正解の理由
    String? reason,

    /// 採用順序（1始まり）
    int? adoptionOrder,
  }) = _Validation;

  const Validation._();

  factory Validation.fromJson(Map<String, dynamic> json) =>
      _$ValidationFromJson(json);
}
