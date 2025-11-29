import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/pages/room_entry_page.dart';
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

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(firebaseAuth: MockFirebaseAuth());

  @override
  Future<MockUser> signInAnonymouslyIfNeeded() async {
    return MockUser(uid: 'test-user');
  }
}

class _FakeParticipantRepository extends ParticipantRepository {
  _FakeParticipantRepository({this.onJoin})
      : super(
          firestore: FakeFirebaseFirestore(),
          authRepository: _FakeAuthRepository(),
        );

  final Future<Participant> Function({
    required String roomId,
    required String displayName,
    String? avatarUrl,
  })? onJoin;

  final List<Map<String, String>> joinRequests = [];

  @override
  Future<Participant> joinRoom({
    required String roomId,
    required String displayName,
    String? avatarUrl,
  }) async {
    joinRequests.add({
      'roomId': roomId,
      'displayName': displayName,
    });
    if (onJoin != null) {
      return onJoin!(
        roomId: roomId,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    }
    return Participant.initial(userId: 'user', displayName: displayName);
  }
}

Widget _buildApp({
  required ParticipantRepository repository,
  required GoRouter router,
}) {
  return ProviderScope(
    overrides: [
      participantRepositoryProvider.overrideWithValue(repository),
    ],
    child: InheritedGoRouter(
      goRouter: router,
      child: const MaterialApp(
        home: RoomEntryPage(),
      ),
    ),
  );
}

void main() {
  group('RoomEntryPage', () {
    testWidgets('空入力ならSnackBarを表示してjoinRoomを呼ばない', (tester) async {
      final repository = _FakeParticipantRepository();
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(repository: repository, router: router),
      );

      await tester.tap(find.byKey(const Key('joinButton')));
      await tester.pump();

      expect(find.text('ルームIDと表示名を入力してください'), findsOneWidget);
      expect(repository.joinRequests, isEmpty);
    });

    testWidgets('参加中はボタンが無効化されローディングが表示される', (tester) async {
      final completer = Completer<Participant>();
      final repository = _FakeParticipantRepository(
        onJoin: ({required roomId, required displayName, String? avatarUrl}) {
          return completer.future;
        },
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(repository: repository, router: router),
      );

      await tester.enterText(
        find.byKey(const Key('roomIdField')),
        'room-123',
      );
      await tester.enterText(
        find.byKey(const Key('displayNameField')),
        'tester',
      );

      await tester.tap(find.byKey(const Key('joinButton')));
      await tester.pump();

      expect(repository.joinRequests.length, 1);

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('joinButton')),
      );
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(
        Participant.initial(userId: 'user', displayName: 'tester'),
      );
      await tester.pump();
      await tester.pump();

      final reEnabledButton = tester.widget<ElevatedButton>(
        find.byKey(const Key('joinButton')),
      );
      expect(reEnabledButton.onPressed, isNotNull);
    });

    testWidgets('joinRoom成功で待機ルームに遷移する', (tester) async {
      final repository = _FakeParticipantRepository(
        onJoin: ({required roomId, required displayName, String? avatarUrl}) {
          return Future.value(
            Participant.initial(userId: 'user', displayName: displayName),
          );
        },
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(repository: repository, router: router),
      );

      await tester.enterText(
        find.byKey(const Key('roomIdField')),
        'room-abc',
      );
      await tester.enterText(
        find.byKey(const Key('displayNameField')),
        'tester',
      );
      await tester.tap(find.byKey(const Key('joinButton')));
      await tester.pump();
      await tester.pump();

      expect(repository.joinRequests.length, 1);
      expect(router.navigations, ['/waiting_room/room-abc']);
    });

    testWidgets('joinRoom失敗時はSnackBarを表示し遷移しない', (tester) async {
      final repository = _FakeParticipantRepository(
        onJoin: ({required roomId, required displayName, String? avatarUrl}) {
          return Future.error(StateError('参加失敗'));
        },
      );
      final router = _RecordingGoRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _buildApp(repository: repository, router: router),
      );

      await tester.enterText(
        find.byKey(const Key('roomIdField')),
        'room-xyz',
      );
      await tester.enterText(
        find.byKey(const Key('displayNameField')),
        'tester',
      );

      await tester.tap(find.byKey(const Key('joinButton')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('参加に失敗しました'),
        findsOneWidget,
      );
      expect(router.navigations, isEmpty);

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('joinButton')),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}
