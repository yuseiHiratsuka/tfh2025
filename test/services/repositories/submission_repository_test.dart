import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:matcher/matcher.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/submission_repository.dart';

/// Firebase Storage を最小限の機能でモックする
class _FakeFirebaseStorage implements FirebaseStorage {
  final Map<String, Uint8List> storedDataMap = {};

  @override
  Reference ref([String? path]) {
    return _FakeReference(this, path ?? '/');
  }

  @override
  Reference refFromURL(String url) => _FakeReference(this, url);

  @override
  String get bucket => 'test-bucket';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReference implements Reference {
  _FakeReference(this.storage, this._path);

  final _FakeFirebaseStorage storage;
  final String _path;

  String get _normalizedPath => _path.startsWith('/') ? _path : '/$_path';

  @override
  Reference child(String path) {
    final base = _normalizedPath.endsWith('/') ? _normalizedPath : '$_normalizedPath/';
    final nextPath = path.startsWith('/') ? path : '$base$path';
    return _FakeReference(storage, nextPath);
  }

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    storage.storedDataMap[_normalizedPath] = data;
    return _FakeUploadTask(this, storage);
  }

  @override
  Future<String> getDownloadURL() async {
    return 'https://fake.storage$_normalizedPath';
  }

  @override
  String get bucket => storage.bucket;

  @override
  String get fullPath => _normalizedPath;

  @override
  String get name => _normalizedPath.split('/').last;

  @override
  Reference? get parent {
    final segments = _normalizedPath.split('/')..removeWhere((segment) => segment.isEmpty);
    if (segments.length <= 1) {
      return null;
    }
    final parentPath = '/${segments.sublist(0, segments.length - 1).join('/')}';
    return _FakeReference(storage, parentPath);
  }

  @override
  Reference get root => storage.ref('/');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUploadTask implements UploadTask {
  _FakeUploadTask(this._reference, this.storage)
      : _future = Future.value(_FakeTaskSnapshot(_reference, storage));

  final _FakeReference _reference;

  @override
  final FirebaseStorage storage;

  final Future<TaskSnapshot> _future;

  @override
  Stream<TaskSnapshot> asStream() => _future.asStream();

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) =>
      _future.catchError(onError, test: test);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr Function() action) =>
      _future.whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<bool> cancel() async => true;

  @override
  Future<bool> resume() async => true;

  @override
  Future<bool> pause() async => true;

  @override
  TaskSnapshot get snapshot => _FakeTaskSnapshot(_reference, storage);

  @override
  Stream<TaskSnapshot> get snapshotEvents => Stream.value(snapshot);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTaskSnapshot implements TaskSnapshot {
  _FakeTaskSnapshot(this.ref, this.storage);

  @override
  final Reference ref;

  @override
  final FirebaseStorage storage;

  @override
  TaskState get state => TaskState.success;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const roomId = 'room-id';
  const userId = 'user-id';

  Uint8List createImageBytes({int width = 10, int height = 10}) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 255));
    return Uint8List.fromList(img.encodePng(image));
  }

  group('SubmissionRepository.submitImageBytes', () {
    late FakeFirebaseFirestore firestore;
    late _FakeFirebaseStorage storage;
    late SubmissionRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      storage = _FakeFirebaseStorage();
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: userId),
        signedIn: true,
      );
      repository = SubmissionRepository(
        firestore: firestore,
        storage: storage,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
    });

    test('ルームが存在しない場合はStateErrorを投げる', () async {
      await expectLater(
        repository.submitImageBytes(
          roomId: roomId,
          displayName: 'user',
          rawBytes: createImageBytes(),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(roomId),
          ),
        ),
      );
    });

    test('currentSequenceを引き継ぎつつStorageのパスとダウンロードURLを保存する', () async {
      const currentSequence = 5;
      await firestore.collection('rooms').doc(roomId).set({
        'currentSequence': currentSequence,
        'totalSubmissions': 1,
      });

      final submissionId = await repository.submitImageBytes(
        roomId: roomId,
        displayName: 'tester',
        rawBytes: createImageBytes(width: 20, height: 12),
      );

      final submissionSnap = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('submissions')
          .doc(submissionId)
          .get();
      final submission = submissionSnap.data();
      expect(submission?['sequenceNumber'], currentSequence);

      final storagePath = submission?['storagePath'] as String?;
      expect(storagePath, isNotNull);
      expect(storagePath, startsWith('rooms/$roomId/submissions/${userId}_'));
      expect(storagePath, endsWith('.jpg'));

      final storedPath = '/$storagePath';
      expect(storage.storedDataMap.containsKey(storedPath), isTrue);

      final expectedUrl = 'https://fake.storage$storedPath';
      expect(submission?['imageUrl'], expectedUrl);

      final room = await firestore.collection('rooms').doc(roomId).get();
      expect(room.data()?['totalSubmissions'], 2);
    });

    test('totalSubmissions更新が失敗しても投稿は成功する', () async {
      final roomRef = firestore.collection('rooms').doc(roomId);
      await roomRef.set({'currentSequence': 1});
      whenCalling(Invocation.method(#update, [anything]))
          .on(roomRef)
          .thenThrow(Exception('update failed'));

      final submissionId = await repository.submitImageBytes(
        roomId: roomId,
        displayName: 'tester',
        rawBytes: createImageBytes(),
      );

      final submissionSnap = await roomRef.collection('submissions').doc(
        submissionId,
      ).get();
      expect(submissionSnap.exists, isTrue);
    });

    test('_compressToJpegで最大辺が800px以下にリサイズされる', () async {
      await firestore.collection('rooms').doc(roomId).set({'currentSequence': 0});

      final submissionId = await repository.submitImageBytes(
        roomId: roomId,
        displayName: 'tester',
        rawBytes: createImageBytes(width: 1600, height: 900),
      );

      final storagePath = (await firestore
              .collection('rooms')
              .doc(roomId)
              .collection('submissions')
              .doc(submissionId)
              .get())
          .data()?['storagePath'] as String;

      final storedBytes = storage.storedDataMap['/$storagePath'];
      expect(storedBytes, isNotNull);

      final decoded = img.decodeJpg(storedBytes!);
      expect(decoded, isNotNull);
      expect(max(decoded!.width, decoded.height) <= 800, isTrue);
    });

    test('デコードできないバイト列ではStateErrorを投げる', () async {
      await firestore.collection('rooms').doc(roomId).set({'currentSequence': 0});

      await expectLater(
        repository.submitImageBytes(
          roomId: roomId,
          displayName: 'tester',
          rawBytes: Uint8List(10),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('読み込み'),
          ),
        ),
      );
    });
  });
}
