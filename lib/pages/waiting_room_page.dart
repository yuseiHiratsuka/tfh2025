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
    super.key,
  });

  final String roomId;

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage> {
  bool _hasNavigatedToPresentation = false;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
    );
  }

  /// マスターがゲーム開始ボタンを押した時の処理
  Future<void> _startGame() async {
    if (_isStarting) return;

    setState(() {
      _isStarting = true;
    });

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
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
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
      body: Background(
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/room_entry'),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '待機ルーム',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ルームID: ${widget.roomId}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 参加者一覧
              Expanded(
                child: participantsAsync.when(
                  data: (participants) {
                    if (participants.isEmpty) {
                      return const Center(
                        child: Text('参加者はまだいません'),
                      );
                    }

                    // 自分の参加者情報を取得
                    Participant? selfParticipant;
                    for (final participant in participants) {
                      if (participant.userId == currentUserId) {
                        selfParticipant = participant;
                        break;
                      }
                    }

                    return Column(
                      children: [
                        // 参加者数
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '参加者: ${participants.length}人',
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              roomAsync.when(
                                data: (room) {
                                  final data = room.data();
                                  final maxPlayers = data?['maxPlayers'];
                                  if (maxPlayers is int && maxPlayers > 0) {
                                    return Text(
                                      '(定員 $maxPlayers人)',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                error: (_, __) => const SizedBox.shrink(),
                                loading: () => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 参加者リスト
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              final participant = participants[index];
                              final isMe = participant.userId == currentUserId;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: participant.isMaster
                                        ? Colors.amber
                                        : theme.colorScheme.primaryContainer,
                                    child: Icon(
                                      participant.isMaster
                                          ? Icons.star
                                          : Icons.person,
                                      color: participant.isMaster
                                          ? Colors.white
                                          : theme
                                              .colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        participant.displayName,
                                        style: TextStyle(
                                          fontWeight: isMe
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'あなた',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                      if (participant.isMaster) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                            },
                          ),
                        ),

                        // ボタンエリア
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: selfParticipant?.isMaster == true
                              ? _buildMasterButton(theme)
                              : _buildWaitingButton(theme),
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
      ),
    );
  }

  /// マスター用の開始ボタン
  Widget _buildMasterButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isStarting ? null : _startGame,
        icon: _isStarting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow),
        label: Text(
          _isStarting ? '開始中...' : 'ゲーム開始',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// 非マスター用の待機中表示
  Widget _buildWaitingButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'マスターの開始を待っています...',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
