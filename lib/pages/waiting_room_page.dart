import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/models/participant.dart';
import 'package:tfh2025/painter.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

class WaitingRoomPage extends ConsumerStatefulWidget {
  const WaitingRoomPage({super.key});

  @override
  ConsumerState<WaitingRoomPage> createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends ConsumerState<WaitingRoomPage> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _displayNameController;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController(text: 'room123');
    _displayNameController = TextEditingController(
      text: 'プレイヤー${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    _roomIdController.addListener(_onRoomIdChanged);
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
    });
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
    final roomId = _roomIdController.text.trim();
    final participantsAsync = roomId.isEmpty
        ? const AsyncValue<List<Participant>>.data([])
        : ref.watch(participantsStreamProvider(roomId));

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
                  return ListView.separated(
                    itemCount: participants.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(participant.displayName),
                        subtitle: Text('参加: ${participant.joinedAt}'),
                        trailing: Text(participant.userId),
                      );
                    },
                  );
                },
                error: (error, _) =>
                    Center(child: Text('参加者取得に失敗しました: $error')),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
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
