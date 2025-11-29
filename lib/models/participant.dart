import 'package:freezed_annotation/freezed_annotation.dart';

import 'room.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

/// 参加者情報
@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    /// ユーザーID（匿名認証のUID）
    required String userId,

    /// 表示名
    required String displayName,

    /// 参加日時
    @TimestampConverter() required DateTime joinedAt,

    /// 準備完了フラグ
    @JsonKey(defaultValue: false) required bool isReady,

    /// ルームマスターかどうか
    @JsonKey(defaultValue: false) required bool isMaster,

    /// アバター画像URL
    String? avatarUrl,

    /// 最後の投稿日時
    @NullableTimestampConverter() DateTime? lastSubmittedAt,
  }) = _Participant;

  const Participant._();

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);

  /// 初期値（参加時）
  factory Participant.initial({
    required String userId,
    required String displayName,
    String? avatarUrl,
    bool isMaster = false,
  }) {
    return Participant(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      joinedAt: DateTime.now(),
      isReady: false,
      isMaster: isMaster,
    );
  }
}
