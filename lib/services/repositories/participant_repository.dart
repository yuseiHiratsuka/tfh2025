import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../models/participant.dart';
import '../providers/firebase_providers.dart';
import 'auth_repository.dart';

/// 参加者に関するデータアクセス
class ParticipantRepository {
  ParticipantRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? AuthRepository();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  /// 参加フロー: 参加者ドキュメントを作成し、ルームの totalParticipants をインクリメント
  Future<Participant> joinRoom({
    required String roomId,
    required String displayName,
    String? avatarUrl,
  }) async {
    debugPrint('[ParticipantRepository] joinRoom: 開始 roomId=$roomId, displayName=$displayName');
    try {
      debugPrint('[ParticipantRepository] 認証を開始します');
      final user = await _authRepository.signInAnonymouslyIfNeeded();
      debugPrint('[ParticipantRepository] 認証成功: userId=${user.uid}');
      
      final participant = Participant.initial(
        userId: user.uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      debugPrint('[ParticipantRepository] Participant作成完了: ${participant.toJson()}');

      final roomRef = _firestore.collection('rooms').doc(roomId);
      final participantRef = roomRef.collection('participants').doc(user.uid);
      debugPrint('[ParticipantRepository] Firestore参照作成完了');

      debugPrint('[ParticipantRepository] トランザクション開始');
      await _firestore.runTransaction((transaction) async {
        final participantSnap = await transaction.get(participantRef);
        if (participantSnap.exists) {
          debugPrint('[ParticipantRepository] 既に参加済みです');
          // 既に参加済みなら何もしない
          return;
        }

        final roomSnap = await transaction.get(roomRef);
        if (!roomSnap.exists) {
          debugPrint('[ParticipantRepository] エラー: ルームが見つかりません roomId=$roomId');
          throw StateError('ルームが見つかりません (roomId: $roomId)');
        }
        debugPrint('[ParticipantRepository] ルーム確認完了');

        transaction.set(participantRef, participant.toJson());
        transaction.update(
          roomRef,
          {'totalParticipants': FieldValue.increment(1)},
        );
        debugPrint('[ParticipantRepository] トランザクション処理完了');
      });

      debugPrint('[ParticipantRepository] joinRoom: 成功');
      return participant;
    } catch (e, stackTrace) {
      debugPrint('[ParticipantRepository] joinRoom: エラー発生 $e');
      debugPrint('[ParticipantRepository] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// 参加者一覧（参加順）のストリーム
  Stream<List<Participant>> watchParticipants(String roomId) {
    final ref = _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('participants')
        .orderBy('joinedAt', descending: false);

    return ref.snapshots().map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Participant.fromJson(data);
        }).toList();
      },
    );
  }
}

/// ParticipantRepository プロバイダー
final participantRepositoryProvider = Provider<ParticipantRepository>(
  (ref) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    final authRepository = ref.watch(authRepositoryProvider);
    return ParticipantRepository(
      firestore: firestore,
      authRepository: authRepository,
    );
  },
);

/// 参加者一覧ストリームのプロバイダー
final participantsStreamProvider =
    StreamProvider.family<List<Participant>, String>(
  (ref, roomId) {
    final repository = ref.watch(participantRepositoryProvider);
    return repository.watchParticipants(roomId);
  },
);
