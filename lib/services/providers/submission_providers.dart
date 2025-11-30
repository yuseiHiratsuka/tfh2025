import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/submission.dart';
import 'package:tfh2025/services/repositories/submission_repository.dart';

/// 採用された投稿一覧を取得するプロバイダー
final adoptedSubmissionsStreamProvider =
    StreamProvider.family<List<Submission>, String>((ref, roomId) {
  final repository = ref.watch(submissionRepositoryProvider);
  return repository.watchAdoptedSubmissions(roomId).map(
        (list) => list.map((data) => Submission.fromJson(data)).toList(),
      );
});

/// 全ての投稿一覧を取得するプロバイダー
final allSubmissionsStreamProvider =
    StreamProvider.family<List<Submission>, String>((ref, roomId) {
  final repository = ref.watch(submissionRepositoryProvider);
  return repository.watchAllSubmissions(roomId).map(
        (list) => list.map((data) => Submission.fromJson(data)).toList(),
      );
});

/// 特定の投稿を監視するプロバイダー
final submissionStreamProvider = StreamProvider.autoDispose
    .family<Submission?, ({String roomId, String submissionId})>(
  (ref, params) {
    final repository = ref.watch(submissionRepositoryProvider);
    return repository.watchSubmission(
      roomId: params.roomId,
      submissionId: params.submissionId,
    );
  },
);
