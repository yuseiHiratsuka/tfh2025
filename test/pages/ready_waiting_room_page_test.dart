import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/pages/ready_waiting_room_page.dart';
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

Widget _buildApp({
  required Widget child,
  required FakeFirebaseFirestore firestore,
  required MockFirebaseAuth auth,
  required GoRouter router,
  Key? scopeKey,
}) {
  return ProviderScope(
    key: scopeKey,
    overrides: [
      firebaseFirestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(auth),
      authStateProvider.overrideWith((ref) => auth.authStateChanges()),
      participantRepositoryProvider.overrideWithValue(
        ParticipantRepository(
          firestore: firestore,
          authRepository: AuthRepository(firebaseAuth: auth),
        ),
      ),
    ],
    child: InheritedGoRouter(
      goRouter: router,
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}

void main() {
  group('ReadyWaitingRoomPage', () {
    testWidgets('status=playingになったら一度だけ/game_startへ遷移する',
        (tester) async {
      const roomId = 'room-id';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
      });
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'user'),
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const ReadyWaitingRoomPage(
            roomId: roomId,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          router: router,
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

    testWidgets('戻るボタンで準備解除してお題提示画面に戻る', (tester) async {
      const roomId = 'room-ready';
      const userId = 'ready-user';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'presenting',
        'readyCount': 1,
        'totalParticipants': 1,
      });
      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .set({
        'userId': userId,
        'displayName': 'user',
        'joinedAt': DateTime(2024),
        'isReady': true,
        'isMaster': false,
        'isAI': false,
      });

      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: userId),
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const ReadyWaitingRoomPage(
            roomId: roomId,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          router: router,
          scopeKey: UniqueKey(),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final participantDoc = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(userId)
          .get();
      expect(participantDoc.data()?['isReady'], isFalse);

      final roomDoc =
          await firestore.collection('rooms').doc(roomId).get();
      expect(roomDoc.data()?['readyCount'], 0);

      expect(router.navigations, ['/theme_presentation/$roomId']);
    });

    testWidgets('準備解除に失敗したらSnackBarを表示して遷移しない', (tester) async {
      const roomId = 'room-error';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('rooms').doc(roomId).set({
        'status': 'presenting',
        'readyCount': 0,
        'totalParticipants': 1,
      });

      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'missing-user'),
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const ReadyWaitingRoomPage(
            roomId: roomId,
            enableRive: false,
          ),
          firestore: firestore,
          auth: auth,
          router: router,
          scopeKey: UniqueKey(),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('準備解除に失敗しました'), findsOneWidget);
      expect(router.navigations, isEmpty);
    });
  });
}
