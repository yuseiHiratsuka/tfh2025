import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';

class RoomRepository {
  RoomRepository({
    FirebaseFirestore? firestore,
    Random? random,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _random = random ?? Random();

  final FirebaseFirestore _firestore;
  final Random _random;

  /// 新しいルームを作成
  Future<Room> createRoom({
    required String password,
    List<String> availableCharacters = _hiraganaList,
    int maxPlayers = 10,
    int timeLimit = 120,
  }) async {
    debugPrint(
      '[RoomRepository] createRoom: password=$password',
    );

    try {
      // 新しいドキュメント参照を作成
      final roomRef = _firestore.collection('rooms').doc();
      final roomId = roomRef.id;

      // ランダムに開始文字とゴール文字を選択
      final startCharacter =
          availableCharacters[_random.nextInt(availableCharacters.length)];
      String goalCharacter;
      do {
        goalCharacter =
            availableCharacters[_random.nextInt(availableCharacters.length)];
      } while (goalCharacter == startCharacter); // 開始文字と同じにならないようにする

      debugPrint(
        '[RoomRepository] ランダム選択: start=$startCharacter, goal=$goalCharacter',
      );

      final room = Room.initial(
        id: roomId,
        startCharacter: startCharacter,
        goalCharacter: goalCharacter,
        maxPlayers: maxPlayers,
        timeLimit: timeLimit,
        password: password,
      );

      await roomRef.set(room.toJson());
      debugPrint('[RoomRepository] createRoom: 成功 roomId=$roomId');

      return room;
    } catch (e, stackTrace) {
      debugPrint('[RoomRepository] createRoom: エラー $e');
      debugPrint('[RoomRepository] スタックトレース: $stackTrace');
      rethrow;
    }
  }

  /// 特定のルーム情報を取得(1回のみ)
  Future<Room?> getRoom(String roomId) async {
    try {
      final doc = await _firestore.collection('rooms').doc(roomId).get();
      if (!doc.exists) return null;
      return Room.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('[RoomRepository] getRoom error: $e');
      return null;
    }
  }

  /// 特定のルーム情報を監視
  Stream<Room?> watchRoom(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Room.fromJson(doc.data()!);
    });
  }
}

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return RoomRepository(firestore: firestore);
});

final roomStreamProvider = StreamProvider.family<Room?, String>((ref, roomId) {
  final repository = ref.watch(roomRepositoryProvider);
  return repository.watchRoom(roomId);
});

/// 五十音のひらがなリスト
const _hiraganaList = [
  'あ',
  'い',
  'う',
  'え',
  'お',
  'か',
  'き',
  'く',
  'け',
  'こ',
  'さ',
  'し',
  'す',
  'せ',
  'そ',
  'た',
  'ち',
  'つ',
  'て',
  'と',
  'な',
  'に',
  'ぬ',
  'ね',
  'の',
  'は',
  'ひ',
  'ふ',
  'へ',
  'ほ',
  'ま',
  'み',
  'む',
  'め',
  'も',
  'や',
  'ゆ',
  'よ',
  'ら',
  'り',
  'る',
  'れ',
  'ろ',
  'わ',
];
