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
    debugPrint(
      '[ParticipantRepository] joinRoom: 開始 roomId=$roomId, displayName=$displayName',
    );
    try {
      debugPrint('[ParticipantRepository] 認証を開始します');
      final user = await _authRepository.signInAnonymouslyIfNeeded();
      debugPrint('[ParticipantRepository] 認証成功: userId=${user.uid}');

      final participant = Participant.initial(
        userId: user.uid,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      debugPrint(
        '[ParticipantRepository] Participant作成完了: ${participant.toJson()}',
      );

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
    debugPrint('[ParticipantRepository] watchParticipants: 開始 roomId=$roomId');

    // ルームの存在確認
    final roomRef = _firestore.collection('rooms').doc(roomId);
    roomRef.get().then((roomSnap) {
      if (roomSnap.exists) {
        debugPrint(
          '[ParticipantRepository] watchParticipants: ルーム存在確認 OK roomId=$roomId',
        );
      } else {
        debugPrint(
          '[ParticipantRepository] watchParticipants: ルーム存在確認 NG roomId=$roomId (ルームが存在しません)',
        );
      }
    }).catchError((Object error, StackTrace stackTrace) {
      debugPrint(
        '[ParticipantRepository] watchParticipants: ルーム存在確認エラー error=$error',
      );
    });

    final ref =
        _firestore.collection('rooms').doc(roomId).collection('participants');

    debugPrint(
      '[ParticipantRepository] watchParticipants: コレクション参照作成完了 path=rooms/$roomId/participants',
    );

    return ref.snapshots().map(
      (snapshot) {
        debugPrint(
          '[ParticipantRepository] watchParticipants: スナップショット受信 docCount=${snapshot.docs.length}, metadata=${snapshot.metadata}',
        );

        final participants = <Participant>[];
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            debugPrint(
              '[ParticipantRepository] watchParticipants: ドキュメント処理 docId=${doc.id}, data=$data',
            );
            final participant = Participant.fromJson(data);
            participants.add(participant);
            debugPrint(
              '[ParticipantRepository] watchParticipants: 参加者追加成功 userId=${participant.userId}, displayName=${participant.displayName}',
            );
          } catch (e, stackTrace) {
            debugPrint(
              '[ParticipantRepository] watchParticipants: エラー発生 docId=${doc.id}, error=$e',
            );
            debugPrint(
              '[ParticipantRepository] watchParticipants: スタックトレース: $stackTrace',
            );
            // エラーが発生したドキュメントはスキップして続行
          }
        }
        // クライアント側でjoinedAtでソート
        participants.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
        debugPrint(
          '[ParticipantRepository] watchParticipants: 完了 participantsCount=${participants.length}',
        );
        return participants;
      },
    ).handleError((Object error, StackTrace stackTrace) {
      debugPrint(
        '[ParticipantRepository] watchParticipants: ストリームエラー error=$error',
      );
      debugPrint(
        '[ParticipantRepository] watchParticipants: スタックトレース: $stackTrace',
      );
      // エラーを再スローして、UIでエラー状態を表示できるようにする
      throw error;
    });
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

extension _RoomDataExt on Map<String, dynamic> {
  int getInt(String key, {int defaultValue = 0}) {
    final value = this[key];
    if (value is int) return value;
    return defaultValue;
  }
}

/// 準備状態を更新し、全員準備完了ならゲーム開始に進める
extension ParticipantRepositoryReady on ParticipantRepository {
  Future<void> setReadyStatus({
    required String roomId,
    required bool isReady,
  }) async {
    debugPrint(
      '[ParticipantRepository] setReadyStatus: roomId=$roomId, isReady=$isReady',
    );
    final user = await _authRepository.signInAnonymouslyIfNeeded();

    final roomRef = _firestore.collection('rooms').doc(roomId);
    final participantRef = roomRef.collection('participants').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final participantSnap = await transaction.get(participantRef);
      if (!participantSnap.exists) {
        throw StateError('まずルームに参加してください');
      }

      final participant = Participant.fromJson(
        participantSnap.data()!,
      );
      final previousReady = participant.isReady;
      if (previousReady == isReady) {
        debugPrint('[ParticipantRepository] 準備状態は既に同じです');
        return;
      }

      final roomSnap = await transaction.get(roomRef);
      if (!roomSnap.exists) {
        throw StateError('ルームが見つかりません (roomId: $roomId)');
      }

      final roomData = roomSnap.data()!;
      final readyCount = roomData.getInt('readyCount');
      final totalParticipants = roomData.getInt('totalParticipants');
      final maxPlayers = roomData.getInt('maxPlayers');
      final status = roomData['status'] as String?;

      // 準備状態更新
      transaction.update(participantRef, {'isReady': isReady});
      transaction.update(
        roomRef,
        {
          'readyCount': FieldValue.increment(isReady ? 1 : -1),
          'updatedAt': DateTime.now(),
        },
      );

      // 全員揃って準備完了ならゲーム開始
      final nextReadyCount = readyCount + (isReady ? 1 : -1);
      final canStart = status == 'waiting' &&
          totalParticipants >= maxPlayers &&
          nextReadyCount >= maxPlayers;

      if (canStart) {
        debugPrint('[ParticipantRepository] 条件を満たしたのでゲーム開始に遷移');
        transaction.update(
          roomRef,
          {
            'status': 'playing',
            'startedAt': DateTime.now(),
          },
        );
      }
    });
  }
}
