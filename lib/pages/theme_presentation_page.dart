import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/services/providers/firebase_providers.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

final _roomStreamProvider =
    StreamProvider.family<DocumentSnapshot<Map<String, dynamic>>, String>(
  (ref, roomId) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    return firestore.collection('rooms').doc(roomId).snapshots();
  },
);

class ThemePresentationPage extends ConsumerStatefulWidget {
  const ThemePresentationPage({
    required this.roomId,
    super.key,
  });

  final String roomId;

  @override
  ConsumerState<ThemePresentationPage> createState() =>
      _ThemePresentationPageState();
}

class _ThemePresentationPageState extends ConsumerState<ThemePresentationPage> {
  bool _hasNavigatedToGame = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
    );
  }

  Future<void> _toggleReady({required bool nextReady}) async {
    try {
      await ref.read(participantRepositoryProvider).setReadyStatus(
            roomId: widget.roomId,
            isReady: nextReady,
          );
      // 準備完了を押したら準備完了待機画面に遷移
      if (nextReady && mounted) {
        context.go('/ready_waiting/${widget.roomId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('準備状態の更新に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final currentUserId =
        authState.value?.uid ?? ref.read(authRepositoryProvider).currentUserId;
    final participantsAsync =
        ref.watch(participantsStreamProvider(widget.roomId));
    final roomAsync = ref.watch(_roomStreamProvider(widget.roomId));

    // ルームステータスがplayingになったらゲーム開始画面へ
    roomAsync.whenData((room) {
      final status = room.data()?['status'] as String?;
      if (status == 'playing' && !_hasNavigatedToGame && mounted) {
        _hasNavigatedToGame = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/game_start/${widget.roomId}');
          }
        });
      }
    });

    return Scaffold(
      body: Background(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // タイトル
                  Text(
                    'お題発表',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // お題情報の表示
                  roomAsync.when(
                    data: (room) {
                      final data = room.data();
                      final startCharacter = data?['startCharacter'] as String?;
                      final goalCharacter = data?['goalCharacter'] as String?;

                      if (startCharacter == null || goalCharacter == null) {
                        return const Text('お題情報を取得中...');
                      }

                      return Column(
                        children: [
                          // スタートとゴール
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCharacterCard(
                                context,
                                label: 'スタート',
                                character: startCharacter,
                                color: Colors.blue,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                              _buildCharacterCard(
                                context,
                                label: 'ゴール',
                                character: goalCharacter,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 説明
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '「$startCharacter」から始まる絵しりとりで\n「$goalCharacter」を目指しましょう！',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      );
                    },
                    error: (error, _) => Text('エラー: $error'),
                    loading: () => const CircularProgressIndicator(),
                  ),

                  const SizedBox(height: 40),

                  // 準備状況
                  participantsAsync.when(
                    data: (participants) {
                      Participant? selfParticipant;
                      for (final participant in participants) {
                        if (participant.userId == currentUserId) {
                          selfParticipant = participant;
                          break;
                        }
                      }

                      final readyCount =
                          participants.where((p) => p.isReady).length;
                      final isSelfReady = selfParticipant?.isReady ?? false;

                      return Column(
                        children: [
                          // 準備状況バー
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '準備完了: $readyCount / ${participants.length}',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 準備完了ボタン
                          SizedBox(
                            width: 280,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _toggleReady(nextReady: !isSelfReady),
                              icon: Icon(
                                isSelfReady
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                              ),
                              label: Text(
                                isSelfReady ? '準備解除' : '準備完了',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelfReady
                                    ? Colors.grey
                                    : theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 参加者の準備状況リスト
                          ...participants.map(
                            (participant) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    participant.isReady
                                        ? Icons.check_circle
                                        : Icons.hourglass_empty,
                                    size: 16,
                                    color: participant.isReady
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    participant.displayName,
                                    style: TextStyle(
                                      color: participant.isReady
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight:
                                          participant.userId == currentUserId
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    error: (error, _) => Text('エラー: $error'),
                    loading: () => const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard(
    BuildContext context, {
    required String label,
    required String character,
    required Color color,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            character,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
