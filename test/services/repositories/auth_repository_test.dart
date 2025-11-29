import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_mocks/src/mock_firebase_app.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';

class _FakeFirebaseApp extends MockFirebaseApp {
  _FakeFirebaseApp()
      : options = const FirebaseOptions(
          apiKey: 'test-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender',
          projectId: 'test-project',
        );

  @override
  final FirebaseOptions options;
}

class _RecordingAuth extends MockFirebaseAuth {
  _RecordingAuth({super.signedIn, super.mockUser}) {
    app = _FakeFirebaseApp();
  }

  int signInCallCount = 0;
  final Queue<Future<UserCredential>> _signInResponses = Queue();

  void enqueueSignIn(Future<UserCredential> responder) {
    _signInResponses.add(responder);
  }

  @override
  Future<UserCredential> signInAnonymously() {
    signInCallCount++;
    if (_signInResponses.isNotEmpty) {
      return _signInResponses.removeFirst();
    }
    return super.signInAnonymously();
  }
}

void main() {
  group('AuthRepository.signInAnonymouslyIfNeeded', () {
    test('currentUserがいる場合はsignInAnonymouslyを呼ばず既存ユーザーを返す', () async {
      final existingUser = MockUser(uid: 'existing-user');
      final auth = _RecordingAuth(mockUser: existingUser, signedIn: true);
      final repository = AuthRepository(firebaseAuth: auth);

      final user = await repository.signInAnonymouslyIfNeeded();

      expect(user.uid, existingUser.uid);
      expect(auth.signInCallCount, 0);
    });

    test('並列呼び出しは同じFutureを共有してsignInAnonymouslyが1回だけ呼ばれる', () async {
      final auth = _RecordingAuth();
      final mockUser = MockUser(uid: 'anon-user', isAnonymous: true);
      auth.mockUser = mockUser;
      final repository = AuthRepository(firebaseAuth: auth);
      final completer = Completer<UserCredential>();
      auth.enqueueSignIn(completer.future);

      final future1 = repository.signInAnonymouslyIfNeeded();
      final future2 = repository.signInAnonymouslyIfNeeded();

      expect(auth.signInCallCount, 1);

      completer.complete(MockUserCredential(true, mockUser: mockUser));
      final users = await Future.wait([future1, future2]);

      expect(users[0].uid, 'anon-user');
      expect(users[1].uid, 'anon-user');
      expect(auth.signInCallCount, 1);
    });

    test('FirebaseAuthException発生後は_signInFutureがクリアされてリトライできる', () async {
      final auth = _RecordingAuth();
      final repository = AuthRepository(firebaseAuth: auth);
      auth.enqueueSignIn(
        Future<UserCredential>.error(
          FirebaseAuthException(
            code: 'internal-error',
            message: 'failed',
          ),
        ),
      );

      await expectLater(
        repository.signInAnonymouslyIfNeeded(),
        throwsA(isA<StateError>()),
      );
      expect(auth.signInCallCount, 1);

      final mockUser = MockUser(uid: 'retry-user', isAnonymous: true);
      auth.mockUser = mockUser;

      final user = await repository.signInAnonymouslyIfNeeded();

      expect(auth.signInCallCount, 2);
      expect(user.uid, mockUser.uid);
    });

    test('未知の例外発生後も_signInFutureがクリアされ再試行できる', () async {
      final auth = _RecordingAuth();
      final repository = AuthRepository(firebaseAuth: auth);
      auth.enqueueSignIn(
        Future<UserCredential>.error(Exception('boom')),
      );

      await expectLater(
        repository.signInAnonymouslyIfNeeded(),
        throwsA(isA<StateError>()),
      );
      expect(auth.signInCallCount, 1);

      final mockUser = MockUser(uid: 'retry-user-2', isAnonymous: true);
      auth.mockUser = mockUser;

      final user = await repository.signInAnonymouslyIfNeeded();

      expect(auth.signInCallCount, 2);
      expect(user.uid, mockUser.uid);
    });
  });
}
