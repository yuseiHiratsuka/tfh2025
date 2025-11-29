import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

/// ゲームルームのステータス
enum RoomStatus {
  /// 参加者募集中
  waiting,

  /// お題提示中（マスターが開始を押した後、全員準備完了待ち）
  presenting,

  /// ゲーム進行中
  playing,

  /// クリア
  success,

  /// 失敗
  failed,
}

/// 失敗理由
enum FailureReason {
  /// タイムアウト
  timeout,

  /// 最大ターン到達
  maxTurns,

  /// ギブアップ
  giveup,
}

/// ゲームルーム
@freezed
abstract class Room with _$Room {
  const factory Room({
    /// ドキュメントID
    required String id,

    /// 作成日時
    @TimestampConverter() required DateTime createdAt,

    /// 更新日時
    @TimestampConverter() required DateTime updatedAt,

    /// ゲーム状態
    required RoomStatus status,

    /// 開始文字（1文字、ひらがな）
    required String startCharacter,

    /// ゴール文字（1文字、ひらがな）
    required String goalCharacter,

    /// 最大参加人数
    required int maxPlayers,

    /// 全体の制限時間（秒）
    required int timeLimit,

    /// 現在のお題文字（1文字、ひらがな）
    required String currentCharacter,

    /// シーケンス番号（楽観的ロック用）
    required int currentSequence,

    /// 使用済みワード配列
    required List<String> usedWords,

    /// チェーン数（採用された回数）
    required int chainCount,

    /// ゴール到達フラグ
    required bool isGoalReached,

    /// 総投稿数
    required int totalSubmissions,

    /// 総参加者数
    required int totalParticipants,

    /// 準備完了している参加者数
    @JsonKey(defaultValue: 0) required int readyCount,

    /// 合言葉（ルーム検索用）
    String? password,

    /// 失敗理由
    FailureReason? failureReason,

    /// ゲーム開始日時
    @NullableTimestampConverter() DateTime? startedAt,

    /// ゴール到達者のuserId
    String? goalReachedBy,

    /// 終了日時
    @NullableTimestampConverter() DateTime? finishedAt,

    /// ゲームスコア
    int? score,

    /// 時間ボーナス
    int? timeBonus,

    /// チェーンボーナス
    int? chainBonus,

    /// 残り時間（秒）
    int? remainingTime,
  }) = _Room;

  const Room._();

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  /// 初期値（ルーム作成時）
  factory Room.initial({
    required String id,
    required String startCharacter,
    required String goalCharacter,
    String? password,
    int maxPlayers = 10,
    int timeLimit = 120,
  }) {
    final now = DateTime.now();
    return Room(
      id: id,
      password: password,
      createdAt: now,
      updatedAt: now,
      status: RoomStatus.waiting,
      startCharacter: startCharacter,
      goalCharacter: goalCharacter,
      maxPlayers: maxPlayers,
      timeLimit: timeLimit,
      currentCharacter: startCharacter,
      currentSequence: 0,
      usedWords: [],
      chainCount: 0,
      isGoalReached: false,
      totalSubmissions: 0,
      totalParticipants: 0,
      readyCount: 0,
    );
  }
}

/// Timestamp型とDateTime型の変換を行うコンバーター
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) {
      throw ArgumentError('Timestamp cannot be null');
    }
    if (json is DateTime) {
      return json;
    }
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    throw ArgumentError('Invalid timestamp format: $json');
  }

  @override
  dynamic toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}

/// Timestamp型とDateTime?型の変換を行うコンバーター（nullable対応）
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    if (json is DateTime) {
      return json;
    }
    if (json is Timestamp) {
      return json.toDate();
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }
    if (json is String) {
      return DateTime.parse(json);
    }
    throw ArgumentError('Invalid timestamp format: $json');
  }

  @override
  dynamic toJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    return Timestamp.fromDate(dateTime);
  }
}
