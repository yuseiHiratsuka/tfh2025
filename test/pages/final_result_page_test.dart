import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/ai_result.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/models/submission.dart';
import 'package:tfh2025/models/validation.dart';
import 'package:tfh2025/pages/final_result_page.dart';
import 'package:tfh2025/services/providers/submission_providers.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';
import 'package:tfh2025/services/repositories/room_repository.dart';

Room _buildRoom({
  required DateTime now,
  required int submissionCount,
  required int participantCount,
}) {
  return Room.initial(
    id: 'room-1',
    startCharacter: 'あ',
    goalCharacter: 'ん',
  ).copyWith(
    status: RoomStatus.success,
    score: 1200,
    chainCount: submissionCount,
    remainingTime: 30,
    startedAt: now.subtract(const Duration(minutes: 2)),
    finishedAt: now,
    totalParticipants: participantCount,
    totalSubmissions: submissionCount,
  );
}

List<Participant> _participants(DateTime now) {
  return [
    Participant.initial(
      userId: 'user1',
      displayName: 'プレイヤー1',
    ).copyWith(joinedAt: now),
    Participant.initial(
      userId: 'user2',
      displayName: 'プレイヤー2',
    ).copyWith(joinedAt: now),
  ];
}

List<Submission> _submissions(DateTime base, int count) {
  final words = [
    ('あめ', 'あ', 'め'),
    ('めだか', 'め', 'か'),
    ('からす', 'か', 'す'),
    ('すずめ', 'す', 'め'),
    ('めんたい', 'め', 'い'),
    ('いくら', 'い', 'ら'),
  ];

  return List.generate(count, (index) {
    final data = words[index];
    final recognizedAt = base.add(Duration(seconds: index * 5));

    return Submission.initial(
      id: 'sub-${index + 1}',
      userId: index.isEven ? 'user1' : 'user2',
      userName: index.isEven ? 'プレイヤー1' : 'プレイヤー2',
      sequenceNumber: index,
      imageUrl: '',
      storagePath: 'storage/$index',
    ).copyWith(
      status: SubmissionStatus.completed,
      aiResult: AIResult(
        word: data.$1,
        firstChar: data.$2,
        lastChar: data.$3,
        recognizedAt: recognizedAt,
      ),
      validation: Validation(
        isValid: true,
        isAdopted: true,
        isGoalReached: index == count - 1,
        validatedAt: recognizedAt.add(const Duration(seconds: 1)),
      ),
    );
  });
}

Widget _buildPage({
  required Room room,
  required List<Submission> submissions,
  required List<Participant> participants,
}) {
  return ProviderScope(
    overrides: [
      roomStreamProvider.overrideWith((ref, _) => Stream.value(room)),
      adoptedSubmissionsStreamProvider.overrideWith(
        (ref, _) => Stream.value(submissions),
      ),
      participantsStreamProvider.overrideWith(
        (ref, _) => Stream.value(participants),
      ),
    ],
    child: const MaterialApp(
      home: FinalResultPage(roomId: 'room-1'),
    ),
  );
}

void main() {
  group('FinalResultPage', () {
    testWidgets('0.8秒ごとにAIイントロと投稿が段階表示される', (tester) async {
      final now = DateTime(2024, 1, 1, 12);
      final participants = _participants(now);
      final submissions = _submissions(now, 2);
      final room = _buildRoom(
        now: now,
        submissionCount: submissions.length,
        participantCount: participants.length,
      );

      await tester.pumpWidget(
        _buildPage(
          room: room,
          submissions: submissions,
          participants: participants,
        ),
      );
      await tester.pump();

      expect(find.text('スタート：「あ」'), findsNothing);

      await tester.pump(const Duration(milliseconds: 810));
      expect(find.text('スタート：「あ」'), findsOneWidget);
      expect(find.text('「あめ」'), findsNothing);

      await tester.pump(const Duration(milliseconds: 810));
      expect(find.text('「あめ」'), findsNothing);

      await tester.pump(const Duration(milliseconds: 810));
      expect(find.text('「あめ」'), findsOneWidget);
      expect(find.text('プレイヤー1'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1620));
      await tester.dragUntilVisible(
        find.text('「めだか」'),
        find.byType(Scrollable),
        const Offset(0, -400),
      );
      await tester.pump();
      expect(find.text('「めだか」'), findsOneWidget);
      expect(find.text('プレイヤー2'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('要素が増えるとスクロール位置が自動で進む', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view
        ..devicePixelRatio = 1.0
        ..physicalSize = const Size(400, 600);

      final now = DateTime(2024, 1, 1, 12);
      final participants = _participants(now);
      final submissions = _submissions(now, 6);
      final room = _buildRoom(
        now: now,
        submissionCount: submissions.length,
        participantCount: participants.length,
      );

      await tester.pumpWidget(
        _buildPage(
          room: room,
          submissions: submissions,
          participants: participants,
        ),
      );
      await tester.pump();

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, 0);

      await tester.pump(const Duration(seconds: 12));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      expect(scrollable.position.pixels, greaterThan(0));
    });
  });
}
