import 'dart:math';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/pages/password_page.dart';
import 'package:tfh2025/providers/loading_provider.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';
import 'package:tfh2025/services/repositories/room_repository.dart';

class _RecordingGoRouter extends GoRouter {
  _RecordingGoRouter()
      : super.routingConfig(
          routingConfig: ValueNotifier(
            RoutingConfig(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );

  final List<String> navigations = [];

  @override
  void go(String location, {Object? extra}) {
    navigations.add(location);
  }
}

final class _LoadingObserver extends ProviderObserver {
  final List<bool> values = [];

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (context.provider == loadingProvider) {
      values.add(newValue! as bool);
    }
  }
}

Widget _buildApp({
  required Widget child,
  required FakeFirebaseFirestore firestore,
  required MockFirebaseAuth auth,
  required RoomRepository roomRepository,
  required ParticipantRepository participantRepository,
  required GoRouter router,
  ProviderObserver? observer,
  Key? scopeKey,
}) {
  return ProviderScope(
    key: scopeKey,
    overrides: [
      firebaseFirestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(auth),
      authStateProvider.overrideWith((ref) => auth.authStateChanges()),
      roomRepositoryProvider.overrideWithValue(roomRepository),
      participantRepositoryProvider.overrideWithValue(participantRepository),
    ],
    observers: [
      if (observer != null) observer,
    ],
    child: InheritedGoRouter(
      goRouter: router,
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}

Finder _textFieldByLabel(String label) {
  return find.widgetWithText(TextFormField, label);
}

void main() {
  group('PasswordPage', () {
    testWidgets('合言葉/プレイヤー名が空ならSnackBarを出して処理しない', (tester) async {
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'user-empty'),
        signedIn: true,
      );
      final roomRepository = RoomRepository(
        firestore: firestore,
        random: Random(1),
      );
      final participantRepository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
      final router = _RecordingGoRouter();
      final observer = _LoadingObserver();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const PasswordPage(
            isCreateMode: true,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          roomRepository: roomRepository,
          participantRepository: participantRepository,
          router: router,
          observer: observer,
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'ルームを作成'));
      await tester.pump();

      expect(find.text('合言葉とプレイヤー名を入力してください'), findsOneWidget);
      expect(router.navigations, isEmpty);
      expect(observer.values, isEmpty);
    });

    testWidgets('作成モードでルーム作成→参加→待機画面に遷移する', (tester) async {
      const password = 'pw123';
      const name = 'たろう';
      final firestore = FakeFirebaseFirestore();
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'creator'),
        signedIn: true,
      );
      final roomRepository = RoomRepository(
        firestore: firestore,
        random: Random(1),
      );
      final participantRepository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
      final router = _RecordingGoRouter();
      final observer = _LoadingObserver();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const PasswordPage(
            isCreateMode: true,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          roomRepository: roomRepository,
          participantRepository: participantRepository,
          router: router,
          observer: observer,
          scopeKey: UniqueKey(),
        ),
      );

      await tester.enterText(_textFieldByLabel('プレイヤー名'), name);
      await tester.enterText(_textFieldByLabel('あいことば'), password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'ルームを作成'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      final rooms = await firestore.collection('rooms').get();
      expect(rooms.docs, hasLength(1));
      final roomId = rooms.docs.single.id;

      final participantDoc = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(auth.currentUser!.uid)
          .get();
      expect(participantDoc.exists, isTrue);
      expect(participantDoc.data()?['displayName'], name);

      expect(router.navigations, ['/waiting_room/$roomId?password=$password']);
      expect(observer.values, [true, false]);
    });

    testWidgets('参加モードでwaitingのルームに参加して遷移する', (tester) async {
      const roomId = 'room-join';
      const password = 'join-pass';
      const name = 'ゲスト';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'password': password,
        'status': 'waiting',
        'totalParticipants': 0,
        'readyCount': 0,
      });

      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'guest'),
        signedIn: true,
      );
      final roomRepository = RoomRepository(
        firestore: firestore,
        random: Random(1),
      );
      final participantRepository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
      final router = _RecordingGoRouter();
      final observer = _LoadingObserver();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const PasswordPage(
            isCreateMode: false,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          roomRepository: roomRepository,
          participantRepository: participantRepository,
          router: router,
          observer: observer,
          scopeKey: UniqueKey(),
        ),
      );

      await tester.enterText(_textFieldByLabel('プレイヤー名'), name);
      await tester.enterText(_textFieldByLabel('あいことば'), password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'ルームに参加'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      final participantDoc = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(auth.currentUser!.uid)
          .get();
      expect(participantDoc.exists, isTrue);
      expect(participantDoc.data()?['displayName'], name);

      expect(
        router.navigations,
        ['/waiting_room/$roomId?password=$password'],
      );
      expect(observer.values, [true, false]);
    });

    testWidgets('waitingのルームが無ければSnackBarを表示してローディングを戻す',
        (tester) async {
      const password = 'used-pass';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc('room-playing').set({
        'password': password,
        'status': 'playing',
      });

      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'user-fail'),
        signedIn: true,
      );
      final roomRepository = RoomRepository(
        firestore: firestore,
        random: Random(1),
      );
      final participantRepository = ParticipantRepository(
        firestore: firestore,
        authRepository: AuthRepository(firebaseAuth: auth),
      );
      final router = _RecordingGoRouter();
      final observer = _LoadingObserver();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const PasswordPage(
            isCreateMode: false,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          roomRepository: roomRepository,
          participantRepository: participantRepository,
          router: router,
          observer: observer,
          scopeKey: UniqueKey(),
        ),
      );

      await tester.enterText(_textFieldByLabel('プレイヤー名'), 'name');
      await tester.enterText(_textFieldByLabel('あいことば'), password);
      await tester.tap(find.widgetWithText(ElevatedButton, 'ルームに参加'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('参加に失敗しました'), findsOneWidget);
      expect(router.navigations, isEmpty);
      expect(observer.values, [true, false]);
    });
  });
}
