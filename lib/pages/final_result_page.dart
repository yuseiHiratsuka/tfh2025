import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/models/room.dart';
import 'package:tfh2025/models/submission.dart';
import 'package:tfh2025/services/providers/submission_providers.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';
import 'package:tfh2025/services/repositories/room_repository.dart';
import 'package:tfh2025/theme/app_theme.dart';

class FinalResultPage extends ConsumerWidget {
  const FinalResultPage({
    required this.roomId,
    super.key,
  });

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomStreamProvider(roomId));
    final submissionsAsync =
        ref.watch(adoptedSubmissionsStreamProvider(roomId));
    final participantsAsync = ref.watch(participantsStreamProvider(roomId));

    return Scaffold(
      body: roomAsync.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('ルームが見つかりません'));
          }

          return Stack(
            children: [
              Container(
                color: const Color(0xFF06B7D8),
                child: CustomScrollView(
                  slivers: [
                    _FinalResultSliverAppBar(room: room),
                    submissionsAsync.when(
                      data: (submissions) {
                        return participantsAsync.when(
                          data: (participants) {
                            return _ResultTimelineSlivers(
                              room: room,
                              submissions: submissions,
                              participants: participants,
                            );
                          },
                          loading: () => const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, st) {
                            debugPrint('Participants Error: $e');
                            debugPrint('Stacktrace: $st');
                            return SliverFillRemaining(
                              child:
                                  Center(child: SelectableText('参加者取得エラー: $e')),
                            );
                          },
                        );
                      },
                      loading: () => const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, st) {
                        debugPrint('Submissions Error: $e');
                        debugPrint('Stacktrace: $st');
                        return SliverFillRemaining(
                          child: Center(child: SelectableText('投稿取得エラー: $e')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _FinalResultFooter(onPressed: () => context.go('/top')),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('Room Error: $e');
          debugPrint('Stacktrace: $st');
          return Center(child: SelectableText('ルーム取得エラー: $e'));
        },
      ),
    );
  }
}

class _HeaderInfoPill extends StatelessWidget {
  const _HeaderInfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FinalResultSliverAppBar extends StatelessWidget {
  const _FinalResultSliverAppBar({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SliverAppBar(
      expandedHeight: 200,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'かす素人',
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(
                      offset: Offset(0, 3),
                      blurRadius: 12,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  '今回のスコア : ${room.score ?? 0}',
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  const _HeaderInfoPill(label: '残りタイム : 0秒'),
                  _HeaderInfoPill(label: 'コンボ数 : ${room.chainCount}回'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultTimelineSlivers extends StatelessWidget {
  const _ResultTimelineSlivers({
    required this.room,
    required this.submissions,
    required this.participants,
  });

  final Room room;
  final List<Submission> submissions;
  final List<Participant> participants;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _AIIntroBubble(room: room),
          for (final submission in submissions) ...[
            const SizedBox(height: 32),
            _SubmissionThread(
              submission: submission,
              participant: participants.firstWhere(
                (p) => p.userId == submission.userId,
                orElse: () => Participant.initial(
                  userId: 'unknown',
                  displayName: 'Unknown',
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _AIIntroBubble extends StatelessWidget {
  const _AIIntroBubble({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.smart_toy, size: 24, color: colorScheme.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'みゃくラクAI',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'スタート：「${room.startCharacter}」',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ゴール：「${room.goalCharacter}」',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubmissionThread extends StatelessWidget {
  const _SubmissionThread({
    required this.submission,
    required this.participant,
  });

  final Submission submission;
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParticipantHeader(
          participant: participant,
          imageUrl: submission.imageUrl,
        ),
        const SizedBox(height: 16),
        _AIResponseBubble(word: submission.aiResult?.word ?? '???'),
      ],
    );
  }
}

class _ParticipantHeader extends StatelessWidget {
  const _ParticipantHeader({
    required this.participant,
    required this.imageUrl,
  });

  final Participant participant;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                participant.displayName,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _SubmissionImageCard(imageUrl: imageUrl),
            ],
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.secondary,
          backgroundImage: participant.avatarUrl != null
              ? NetworkImage(participant.avatarUrl!)
              : null,
          child: participant.avatarUrl == null
              ? Text(
                  participant.displayName.isNotEmpty
                      ? participant.displayName[0]
                      : '?',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _SubmissionImageCard extends StatelessWidget {
  const _SubmissionImageCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Center(
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
      ),
    );
  }
}

class _AIResponseBubble extends StatelessWidget {
  const _AIResponseBubble({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.smart_toy, size: 24, color: colorScheme.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'みゃくラクAI',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '「$word」',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinalResultFooter extends StatelessWidget {
  const _FinalResultFooter({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 4,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: colorScheme.shadow,
                width: 2,
              ),
            ),
          ),
          child: Text(
            'ホームへ',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
