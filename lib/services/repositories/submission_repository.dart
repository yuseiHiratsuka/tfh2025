import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;

import '../providers/firebase_providers.dart';
import 'auth_repository.dart';

/// 投稿フロー（圧縮→Storageアップロード→Firestore作成）を扱うリポジトリ
class SubmissionRepository {
  SubmissionRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _authRepository = authRepository ?? AuthRepository();

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final AuthRepository _authRepository;

  /// 任意のバイト列を受け取り、投稿ドキュメントを作成する
  Future<String> submitImageBytes({
    required String roomId,
    required String displayName,
    required Uint8List rawBytes,
  }) async {
    debugPrint('[SubmissionRepository] submitImageBytes roomId=$roomId');
    final user = await _authRepository.signInAnonymouslyIfNeeded();
    final userId = user.uid;

    // 圧縮
    final compressed = _compressToJpeg(rawBytes);

    // ルーム取得（currentSequenceなどを使用）
    final roomRef = _firestore.collection('rooms').doc(roomId);
    final roomSnap = await roomRef.get();
    if (!roomSnap.exists) {
      throw StateError('ルームが存在しません (roomId: $roomId)');
    }
    final roomData = roomSnap.data() ?? {};
    final currentSequence = (roomData['currentSequence'] as num?)?.toInt() ?? 0;

    // Storage アップロード
    final storagePath = _buildStoragePath(roomId: roomId, userId: userId);
    final storageRef = _storage.ref().child(storagePath);
    await storageRef.putData(
      compressed,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await storageRef.getDownloadURL();

    // Firestore 投稿作成
    final submissionsRef = roomRef.collection('submissions');
    final submissionRef = submissionsRef.doc();
    await submissionRef.set({
      'id': submissionRef.id,
      'userId': userId,
      'userName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'sequenceNumber': currentSequence,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'status': 'processing',
      'aiResult': null,
      'validation': null,
    });

    // totalSubmissions は best-effort
    await roomRef.update({
      'totalSubmissions': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError(
      (Object error, StackTrace stackTrace) => debugPrint(
        '[SubmissionRepository] totalSubmissions更新失敗: $error',
      ),
    );

    debugPrint(
      '[SubmissionRepository] 投稿完了 submissionId=${submissionRef.id} sequence=$currentSequence',
    );
    return submissionRef.id;
  }

  Uint8List _compressToJpeg(Uint8List rawBytes) {
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw StateError('画像の読み込みに失敗しました');
    }

    const target = 800;
    final maxSide = max(decoded.width, decoded.height);
    final resized = maxSide > target
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? target : null,
            height: decoded.height > decoded.width ? target : null,
            interpolation: img.Interpolation.average,
          )
        : decoded;

    final encoded = img.encodeJpg(resized, quality: 85);
    return Uint8List.fromList(encoded);
  }

  String _buildStoragePath({
    required String roomId,
    required String userId,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'rooms/$roomId/submissions/${userId}_$timestamp.jpg';
  }
}

/// SubmissionRepository プロバイダー
final submissionRepositoryProvider = Provider<SubmissionRepository>(
  (ref) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    final storage = ref.watch(firebaseStorageProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    return SubmissionRepository(
      firestore: firestore,
      storage: storage,
      authRepository: authRepository,
    );
  },
);
