import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/painter.dart';
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
  const WaitingRoomPage({super.key});

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _displayNameController;
  bool _isJoining = false;
  bool _hasNavigatedToGame = false;

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController(text: 'L7qqB8lctYU9niXqOKOT');
    _displayNameController = TextEditingController(
      text: 'プレイヤー${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    _roomIdController.addListener(_onRoomIdChanged);
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
    );
  }

  @override
  void dispose() {
    _roomIdController.removeListener(_onRoomIdChanged);
    _roomIdController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _onRoomIdChanged() {
    setState(() {
      // roomIdが変更されたときに再ビルドして参加者一覧を更新
      _hasNavigatedToGame = false;
    });
  }

  Future<void> _toggleReady({
    required String roomId,
    required bool nextReady,
  }) async {
    try {
      await ref
          .read(participantRepositoryProvider)
          .setReadyStatus(roomId: roomId, isReady: nextReady);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('準備状態の更新に失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _joinRoom() async {
    final roomIdText = _roomIdController.text.trim();
    final nameText = _displayNameController.text.trim();
    debugPrint(
      '[WaitingRoomPage] _joinRoom: 開始 roomId=$roomIdText, displayName=$nameText',
    );

    if (roomIdText.isEmpty || nameText.isEmpty) {
      debugPrint('[WaitingRoomPage] バリデーションエラー: 入力が空です');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ルームIDと表示名を入力してください')),
        );
      }
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      debugPrint('[WaitingRoomPage] joinRoom呼び出し開始');
      await ref.read(participantRepositoryProvider).joinRoom(
            roomId: roomIdText,
            displayName: nameText,
          );
      debugPrint('[WaitingRoomPage] joinRoom成功');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ルームに参加しました')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[WaitingRoomPage] joinRoomエラー: $e');
      debugPrint('[WaitingRoomPage] スタックトレース: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('参加に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final roomId = _roomIdController.text.trim();
    final currentUserId =
        authState.value?.uid ?? ref.read(authRepositoryProvider).currentUserId;
    final participantsAsync = roomId.isEmpty
        ? const AsyncValue<List<Participant>>.data([])
        : ref.watch(participantsStreamProvider(roomId));
    final roomAsync = roomId.isEmpty
        ? const AsyncValue<DocumentSnapshot<Map<String, dynamic>>>.loading()
        : ref.watch(_roomStreamProvider(roomId));

    // ルームステータスがplayingになったらお題提示画面へ
    roomAsync.whenData((room) {
      final status = room.data()?['status'] as String?;
      if (status == 'playing' && !_hasNavigatedToGame && mounted) {
        _hasNavigatedToGame = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go('/theme_presentation');
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('待機ルーム'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(
                labelText: 'ルームID',
                hintText: '既存のroomIdを入力',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: '表示名',
                hintText: 'プレイヤー名を入力',
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
            // お題情報の表示
            roomAsync.when(
              data: (room) {
                final data = room.data();
                final startCharacter = data?['startCharacter'] as String?;
                final goalCharacter = data?['goalCharacter'] as String?;

                if (startCharacter == null || goalCharacter == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'お題情報',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'スタート',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    startCharacter,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.arrow_forward, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Text(
                                    'ゴール',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    goalCharacter,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
            Text(
              '参加者一覧',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            participantsAsync.when(
              data: (participants) {
                if (roomId.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('ルームIDを入力してください')),
                  );
                }
                if (participants.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('参加者はまだいません')),
                  );
                }
                Participant? selfParticipant;
                for (final participant in participants) {
                  if (participant.userId == currentUserId) {
                    selfParticipant = participant;
                    break;
                  }
                }
                final readyCount = participants.where((p) => p.isReady).length;
                final isSelfReady = selfParticipant?.isReady ?? false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('準備状況: $readyCount / ${participants.length}'),
                        const SizedBox(width: 12),
                        roomAsync.when(
                          data: (room) {
                            final data = room.data();
                            final maxPlayers = data?['maxPlayers'];
                            if (maxPlayers is int && maxPlayers > 0) {
                              return Text('(定員 $maxPlayers 人)');
                            }
                            return const SizedBox.shrink();
                          },
                          error: (_, __) => const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: currentUserId == null
                              ? null
                              : () => _toggleReady(
                                    roomId: roomId,
                                    nextReady: !isSelfReady,
                                  ),
                          icon: Icon(
                            isSelfReady
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                          ),
                          label: Text(isSelfReady ? '準備解除' : '準備完了する'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: participants.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final participant = participants[index];
                        return ListTile(
                          leading: Icon(
                            participant.isReady
                                ? Icons.check_circle
                                : Icons.person,
                            color: participant.isReady ? Colors.green : null,
                          ),
                          title: Text(participant.displayName),
                          subtitle: Text('参加: ${participant.joinedAt}'),
                          trailing: Text(participant.userId),
                        );
                      },
                    ),
                  ],
                );
              },
              error: (error, _) => Center(child: Text('参加者取得に失敗しました: $error')),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
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
                        builder: (context) => const PainterPage(),
                      ),
                    );
                  },
                  child: const Text('ペインター画面へ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
