import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/canvas.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final roomId = _roomIdController.text.trim();
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
      appBar: AppBar(
        title: const Text('待機ルーム'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roomIdController,
              decoration: InputDecoration(
                labelText: 'ルームID',
                hintText: '既存のroomIdを入力',
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                labelText: '表示名',
                hintText: 'プレイヤー名を入力',
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 3),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isJoining ? null : _joinRoom,
                icon: _isJoining
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(_isJoining ? '参加中...' : 'ルームに参加'),
              ),
            ),
            const Divider(height: 32),
            Text(
              '参加者一覧',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: participantsAsync.when(
                data: (participants) {
                  if (roomId.isEmpty) {
                    return const Center(child: Text('ルームIDを入力してください'));
                  }
                  if (participants.isEmpty) {
                    return const Center(child: Text('参加者はまだいません'));
                  }
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/theme_presentation'),
                  child: const Text('お題提示画面へ'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const CanvasPage(),
                      ),
                    );
                  },
                  child: const Text('キャンバス画面へ'),
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
