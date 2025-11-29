import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/pages/theme_presentation_page.dart';
import 'package:tfh2025/pages/waiting_room_page.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

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

Participant _participant({
  required String userId,
  required bool isMaster,
}) {
  return Participant(
    userId: userId,
    displayName: 'user-$userId',
    joinedAt: DateTime(2024),
    isReady: false,
    isMaster: isMaster,
    isAI: false,
  );
}

Widget _buildApp({
  required Widget child,
  required String roomId,
  required FakeFirebaseFirestore firestore,
  required MockFirebaseAuth auth,
  required GoRouter router,
  required Stream<List<Participant>> participantsStream,
  AsyncValue<List<Participant>>? participantsOverride,
  Key? scopeKey,
}) {
  final overrides = [
    firebaseFirestoreProvider.overrideWithValue(firestore),
    firebaseAuthProvider.overrideWithValue(auth),
    authStateProvider.overrideWith((ref) => auth.authStateChanges()),
    if (participantsOverride != null)
      participantsStreamProvider(roomId).overrideWithValue(participantsOverride)
    else
      participantsStreamProvider.overrideWith(
        (ref, _) => participantsStream,
      ),
  ];

  return ProviderScope(
    key: scopeKey,
    overrides: overrides,
    child: InheritedGoRouter(
      goRouter: router,
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}

void main() {
  group('WaitingRoomPage/ThemePresentationPage', () {
    testWidgets('WaitingRoomPageはstatusがpresentingになったときに一度だけ遷移する',
        (tester) async {
      const roomId = 'room-id';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
      });

      final mockUser = MockUser(uid: 'master-user');
      final auth = MockFirebaseAuth(
        mockUser: mockUser,
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const WaitingRoomPage(roomId: roomId),
          roomId: roomId,
          firestore: firestore,
          auth: auth,
          router: router,
          participantsStream: Stream.value([
            _participant(userId: mockUser.uid, isMaster: true),
          ]),
        ),
      );

      await tester.pump();
      expect(router.navigations, isEmpty);

      await firestore.collection('rooms').doc(roomId).update({
        'status': 'presenting',
      });
      await tester.pump();
      await tester.pump();

      expect(router.navigations, ['/theme_presentation/$roomId']);

      await firestore.collection('rooms').doc(roomId).update({
        'status': 'presenting',
      });
      await tester.pump();
      await tester.pump();

      expect(router.navigations.length, 1);
    });

    testWidgets('ThemePresentationPageはstatusがplayingになったときに一度だけ遷移する',
        (tester) async {
      const roomId = 'room-id';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'presenting',
        'startCharacter': 'A',
        'goalCharacter': 'B',
      });

      final mockUser = MockUser(uid: 'player-user');
      final auth = MockFirebaseAuth(
        mockUser: mockUser,
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const ThemePresentationPage(roomId: roomId),
          roomId: roomId,
          firestore: firestore,
          auth: auth,
          router: router,
          participantsStream: Stream.value([
            _participant(userId: mockUser.uid, isMaster: false),
          ]),
        ),
      );

      await tester.pump();
      expect(router.navigations, isEmpty);

      await firestore.collection('rooms').doc(roomId).update({
        'status': 'playing',
      });
      await tester.pump();
      await tester.pump();

      expect(router.navigations, ['/game_start/$roomId']);

      await firestore.collection('rooms').doc(roomId).update({
        'status': 'playing',
      });
      await tester.pump();
      await tester.pump();

      expect(router.navigations.length, 1);
    });

    testWidgets('WaitingRoomPageはマスターと非マスターでボタン表示が切り替わる', (tester) async {
      const roomId = 'room-id';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
      });
      final masterRouter = _RecordingGoRouter();
      addTearDown(masterRouter.dispose);

      final masterUser = MockUser(uid: 'master-user');
      final masterAuth = MockFirebaseAuth(mockUser: masterUser, signedIn: true);

      await tester.pumpWidget(
        _buildApp(
          child: const WaitingRoomPage(roomId: roomId),
          roomId: roomId,
          firestore: firestore,
          auth: masterAuth,
          router: masterRouter,
          participantsStream: Stream.value([
            _participant(userId: masterUser.uid, isMaster: true),
            _participant(userId: 'guest', isMaster: false),
          ]),
          scopeKey: UniqueKey(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('ゲーム開始'), findsOneWidget);
      expect(find.text('マスターの開始を待っています...'), findsNothing);

      final guestUser = MockUser(uid: 'guest');
      final guestAuth = MockFirebaseAuth(mockUser: guestUser, signedIn: true);
      final guestRouter = _RecordingGoRouter();
      addTearDown(guestRouter.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const WaitingRoomPage(roomId: roomId),
          roomId: roomId,
          firestore: firestore,
          auth: guestAuth,
          router: guestRouter,
          participantsStream: Stream.value([
            _participant(userId: masterUser.uid, isMaster: true),
            _participant(userId: guestUser.uid, isMaster: false),
          ]),
          scopeKey: UniqueKey(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('マスターの開始を待っています...'), findsOneWidget);
      expect(find.text('ゲーム開始'), findsNothing);
    });

    testWidgets('参加者ストリームがエラーの場合はエラーメッセージを表示する', (tester) async {
      const roomId = 'room-id';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
      });

      final mockUser = MockUser(uid: 'any-user');
      final auth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const WaitingRoomPage(roomId: roomId),
          roomId: roomId,
          firestore: firestore,
          auth: auth,
          router: router,
          participantsStream: const Stream<List<Participant>>.empty(),
          participantsOverride: const AsyncError<List<Participant>>(
            'boom',
            StackTrace.empty,
          ),
          scopeKey: UniqueKey(),
        ),
      );

      await tester.pump();
      expect(find.textContaining('エラー: boom'), findsOneWidget);
    });
  });
}
