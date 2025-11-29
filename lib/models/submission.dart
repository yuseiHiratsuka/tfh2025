import 'package:freezed_annotation/freezed_annotation.dart';

import 'ai_result.dart';
import 'room.dart';
import 'validation.dart';

part 'submission.freezed.dart';
part 'submission.g.dart';

/// 投稿の処理状態
enum SubmissionStatus {
  /// AI認識中
  processing,

  /// AI認識完了
  completed,

  /// AI認識失敗
  failed,
}

/// 投稿された絵の情報
@freezed
abstract class Submission with _$Submission {
  const factory Submission({
    /// ドキュメントID
    required String id,

    /// 投稿者ID
    required String userId,

    /// 投稿者名（非正規化）
    required String userName,

    /// 投稿日時
    @TimestampConverter() required DateTime createdAt,

    /// 投稿時のシーケンス番号
    required int sequenceNumber,

    /// Storage公開URL
    required String imageUrl,

    /// Storage内パス
    required String storagePath,

    /// 処理状態
    required SubmissionStatus status,

    /// AI認識結果
    AIResult? aiResult,

    /// 検証結果
    Validation? validation,
  }) = _Submission;

  const Submission._();

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);

  /// 初期値（投稿直後）
  factory Submission.initial({
    required String id,
    required String userId,
    required String userName,
    required int sequenceNumber,
    required String imageUrl,
    required String storagePath,
  }) {
    return Submission(
      id: id,
      userId: userId,
      userName: userName,
      createdAt: DateTime.now(),
      sequenceNumber: sequenceNumber,
      imageUrl: imageUrl,
      storagePath: storagePath,
      status: SubmissionStatus.processing,
    );
  }
}
