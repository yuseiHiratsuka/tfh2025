import '../data/datasources/firestore_datasource.dart';

/// テストデータのリポジトリ層
/// ビジネスロジックを担当
class TestRepository {
  final FirestoreDatasource _datasource;
  static const String _defaultCollectionName = 'test_texts';

  TestRepository({FirestoreDatasource? datasource})
    : _datasource = datasource ?? FirestoreDatasource();

  /// テスト文字列を保存
  ///x
  /// [text] 保存するテキスト
  /// [collectionName] コレクション名（省略時はデフォルト）
  /// 戻り値: 保存されたドキュメントID
  Future<String> saveTestText({
    required String text,
    String? collectionName,
  }) async {
    if (text.isEmpty) {
      throw ArgumentError('テキストが空です');
    }

    return await _datasource.saveTestText(
      collectionName: collectionName ?? _defaultCollectionName,
      text: text,
    );
  }

  /// テスト文字列を取得
  ///
  /// [collectionName] コレクション名（省略時はデフォルト）
  /// [documentId] 特定のドキュメントID（省略可能）
  /// 戻り値: テキストデータのリスト
  Future<List<Map<String, dynamic>>> getTestTexts({
    String? collectionName,
    String? documentId,
  }) async {
    return await _datasource.getTestTexts(
      collectionName: collectionName ?? _defaultCollectionName,
      documentId: documentId,
    );
  }
}
