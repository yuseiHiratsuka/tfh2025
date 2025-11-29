import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';

class RoomRepository {
  RoomRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// 特定のルーム情報を取得（1回のみ）
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

