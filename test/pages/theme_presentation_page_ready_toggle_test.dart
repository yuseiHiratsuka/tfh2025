import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/pages/theme_presentation_page.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';

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

Future<void> _prepareFirestore({
  required FakeFirebaseFirestore firestore,
  required String roomId,
  required List<Participant> participants,
}) async {
  await firestore.collection('rooms').doc(roomId).set({
    'status': 'presenting',
    'startCharacter': 'あ',
    'goalCharacter': 'い',
    'readyCount': participants.where((p) => p.isReady).length,
    'totalParticipants': participants.length,
  });

  final participantsRef =
      firestore.collection('rooms').doc(roomId).collection('participants');
  for (final participant in participants) {
    await participantsRef.doc(participant.userId).set(participant.toJson());
  }
}

Widget _buildApp({
  required Widget child,
  required FakeFirebaseFirestore firestore,
  required MockFirebaseAuth auth,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      firebaseFirestoreProvider.overrideWithValue(firestore),
      firebaseAuthProvider.overrideWithValue(auth),
      authStateProvider.overrideWith((ref) => auth.authStateChanges()),
    ],
    child: InheritedGoRouter(
      goRouter: router,
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}

Participant _participant({
  required String userId,
  required bool isReady,
}) {
  return Participant(
    userId: userId,
    displayName: 'user-$userId',
    joinedAt: DateTime(2024),
    isReady: isReady,
    isMaster: false,
    isAI: false,
  );
}

Color? _buttonColor(WidgetTester tester, Finder buttonFinder) {
  final button = tester.widget<ElevatedButton>(buttonFinder);
  return button.style?.backgroundColor?.resolve({});
}

void main() {
  group('ThemePresentationPage 準備トグル', () {
    testWidgets('準備ボタン押下でsetReadyStatusが呼ばれ、表示が更新される',
        (tester) async {
      const roomId = 'room-id';
      const selfUserId = 'self';
      final firestore = FakeFirebaseFirestore();
      await _prepareFirestore(
        firestore: firestore,
        roomId: roomId,
        participants: [
          _participant(userId: selfUserId, isReady: false),
          _participant(userId: 'other', isReady: false),
        ],
      );

      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: selfUserId),
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const ThemePresentationPage(roomId: roomId),
          firestore: firestore,
          auth: auth,
          router: router,
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final buttonFinder =
          find.byWidgetPredicate((widget) => widget is ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('おぼえた！'), findsOneWidget);

      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pumpAndSettle();

      final participantDoc = await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(selfUserId)
          .get();
      final roomDoc =
          await firestore.collection('rooms').doc(roomId).get();

      expect(participantDoc.data()?['isReady'], isTrue);
      expect(roomDoc.data()?['readyCount'], 1);
      expect(find.text('待機中...'), findsOneWidget);
      expect(router.navigations, contains('/ready_waiting/$roomId'));
    });

    testWidgets('参加者ストリーム更新で準備表示とボタン状態が切り替わる', (tester) async {
      const roomId = 'room-id';
      const selfUserId = 'self';
      final firestore = FakeFirebaseFirestore();
      await _prepareFirestore(
        firestore: firestore,
        roomId: roomId,
        participants: [
          _participant(userId: selfUserId, isReady: false),
          _participant(userId: 'other', isReady: false),
        ],
      );

      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: selfUserId),
        signedIn: true,
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(
          child: const ThemePresentationPage(roomId: roomId),
          firestore: firestore,
          auth: auth,
          router: router,
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      final buttonFinder =
          find.byWidgetPredicate((widget) => widget is ElevatedButton);
      expect(buttonFinder, findsOneWidget);
      expect(find.text('おぼえた！'), findsOneWidget);

      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(selfUserId)
          .update({'isReady': true});

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('待機中...'), findsOneWidget);

      await firestore
          .collection('rooms')
          .doc(roomId)
          .collection('participants')
          .doc(selfUserId)
          .update({'isReady': false});

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('おぼえた！'), findsOneWidget);
    });
  });
}
