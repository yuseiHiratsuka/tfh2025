import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfh2025/services/data/datasources/firestore_datasource.dart';
import 'package:tfh2025/services/repositories/test_repository.dart';

void main() {
  group('TestRepository with FakeFirestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreDatasource datasource;
    late TestRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      datasource = FirestoreDatasource(firestore: fakeFirestore);
      repository = TestRepository(datasource: datasource);
    });

    test('saveTestTextが空文字列でArgumentErrorを投げる', () async {
      expect(
        repository.saveTestText(text: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('デフォルトのコレクション名がdatasourceに伝搬する', () async {
      final docId = await repository.saveTestText(text: 'hello');

      final saved = await fakeFirestore
          .collection('test_texts')
          .doc(docId)
          .get();

      expect(saved.exists, isTrue);
      expect(saved.data()?['text'], 'hello');
    });

    test('カスタムコレクション名がdatasourceに伝搬する', () async {
      const customCollection = 'custom_collection';

      final docId = await repository.saveTestText(
        text: 'custom',
        collectionName: customCollection,
      );

      final defaultDocs =
          await fakeFirestore.collection('test_texts').get();
      final customDoc = await fakeFirestore
          .collection(customCollection)
          .doc(docId)
          .get();

      expect(defaultDocs.docs, isEmpty);
      expect(customDoc.exists, isTrue);
      expect(customDoc.data()?['text'], 'custom');
    });
  });

  group('FirestoreDatasource.getTestTexts with FakeFirestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreDatasource datasource;
    const collectionName = 'test_texts';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      datasource = FirestoreDatasource(firestore: fakeFirestore);
    });

    test('documentId指定で存在しない場合は空リストを返す', () async {
      final result = await datasource.getTestTexts(
        collectionName: collectionName,
        documentId: 'missing-id',
      );

      expect(result, isEmpty);
    });

    test('documentId指定で存在する場合はidフィールド付きでマッピングする', () async {
      final docRef = await fakeFirestore.collection(collectionName).add({
        'text': 'stored text',
      });

      final result = await datasource.getTestTexts(
        collectionName: collectionName,
        documentId: docRef.id,
      );

      expect(result, hasLength(1));
      expect(result.single['id'], docRef.id);
      expect(result.single['text'], 'stored text');
    });
  });
}
