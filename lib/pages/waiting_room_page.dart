import 'package:async/async.dart';
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

class WaitingRoomPage extends ConsumerStatefulWidget {
  const WaitingRoomPage({
    required this.roomId,
    required this.password,
    super.key,
  });

  final String roomId;
  final String password;

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage> {
  bool _hasNavigatedToPresentation = false;

  final cacheStrategy = AsyncCache<void>.ephemeral();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
    );
  }

  /// マスターがゲーム開始ボタンを押した時の処理
  Future<void> _startGame() async {
    try {
      await ref.read(participantRepositoryProvider).startPresentation(
            roomId: widget.roomId,
          );
      debugPrint('[WaitingRoomPage] ゲーム開始処理成功');
    } catch (e) {
      debugPrint('[WaitingRoomPage] ゲーム開始処理エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ゲーム開始に失敗しました: $e')),
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

    // ルームステータスがpresentingになったらお題提示画面へ
    roomAsync.whenData((room) {
      final status = room.data()?['status'] as String?;
      if (status == 'presenting' && !_hasNavigatedToPresentation && mounted) {
        _hasNavigatedToPresentation = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/theme_presentation/${widget.roomId}');
          }
        });
      }
    });

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Background(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // 参加者一覧
                Expanded(
                  child: participantsAsync.when(
                    data: (participants) {
                      if (participants.isEmpty) {
                        return const Center(
                          child: Text('参加者はまだいません'),
                        );
                      }

                      for (final participant in participants) {
                        if (participant.userId == currentUserId) {
                          break;
                        }
                      }

                      return Column(
                        children: [
                          Text(
                            'このルームの「あいことば」は',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '「${widget.password}」',
                                  style: theme.textTheme.bodyLarge,
                                ),
                                TextSpan(
                                  text: 'です',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'メンバーの参加を待っています…',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // 参加者リスト
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemCount: participants.length,
                              itemBuilder: (context, index) {
                                final participant = participants[index];
                                final isMe =
                                    participant.userId == currentUserId;

                                return Padding(
                                  padding: index == participants.length - 1
                                      ? const EdgeInsets.only(
                                          bottom: 80,
                                        )
                                      : EdgeInsetsGeometry.zero,
                                  child: _PlayerListTile(
                                    displayName: participant.displayName,
                                    isMe: isMe,
                                    isMaster: participant.isMaster,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                    error: (error, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text('エラー: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/room_entry'),
                            child: const Text('戻る'),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          participantsAsync.when(
            data: (participants) {
              Participant? selfParticipant;

              for (final participant in participants) {
                if (participant.userId == currentUserId) {
                  selfParticipant = participant;
                  break;
                }
              }

              return SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: selfParticipant?.isMaster == true
                      ? _buildMasterButton(theme)
                      : _buildWaitingButton(
                          theme,
                        ),
                ),
              );
            },
            error: (_, __) => const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// マスター用の開始ボタン
  Widget _buildMasterButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          await cacheStrategy.fetch(() async {
            await _startGame();
          });
        },
        child: const Text(
          'ゲーム開始',
        ),
      ),
    );
  }

  /// 非マスター用の待機中表示
  Widget _buildWaitingButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('ゲーム開始を待っています...'),
      ),
    );
  }
}

class _PlayerListTile extends StatelessWidget {
  const _PlayerListTile({
    required this.displayName,
    required this.isMe,
    required this.isMaster,
  });

  final String displayName;
  final bool isMe;
  final bool isMaster;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.transparent,
      child: ListTile(
        tileColor: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
        leading: CircleAvatar(
          backgroundColor:
              isMaster ? Colors.amber : theme.colorScheme.primaryContainer,
          child: Icon(
            isMaster ? Icons.star : Icons.person,
            color:
                isMaster ? Colors.white : theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'あなた',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            if (isMaster) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'マスター',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
