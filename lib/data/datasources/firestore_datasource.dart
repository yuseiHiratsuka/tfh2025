import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestoreへの直接アクセスを担当するデータソース層
class FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// テスト文字列をFirestoreに保存
  ///
  /// [collectionName] コレクション名
  /// [text] 保存するテキスト
  /// 戻り値: 保存されたドキュメントID
  Future<String> saveTestText({
    required String collectionName,
    required String text,
  }) async {
    try {
      final docRef = await _firestore.collection(collectionName).add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Firestoreへの保存に失敗しました: $e');
    }
  }

  /// テスト文字列を取得
  ///
  /// [collectionName] コレクション名
  /// [documentId] ドキュメントID（省略可能）
  /// 戻り値: テキストのリスト
  Future<List<Map<String, dynamic>>> getTestTexts({
    required String collectionName,
    String? documentId,
  }) async {
    try {
      QuerySnapshot querySnapshot;

      if (documentId != null) {
        final docSnapshot = await _firestore
            .collection(collectionName)
            .doc(documentId)
            .get();

        if (!docSnapshot.exists) {
          return [];
        }

        return [
          {'id': docSnapshot.id, ...docSnapshot.data() as Map<String, dynamic>},
        ];
      } else {
        querySnapshot = await _firestore.collection(collectionName).get();
      }

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      throw Exception('Firestoreからの取得に失敗しました: $e');
    }
  }
}
