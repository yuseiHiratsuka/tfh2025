import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/providers/loading_provider.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

class RoomEntryPage extends ConsumerStatefulWidget {
  const RoomEntryPage({super.key});

  @override
  ConsumerState<RoomEntryPage> createState() => _RoomEntryPageState();
}

class _RoomEntryPageState extends ConsumerState<RoomEntryPage> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController();
    _displayNameController = TextEditingController(
      text: 'プレイヤー${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final roomIdText = _roomIdController.text.trim();
    final nameText = _displayNameController.text.trim();
    debugPrint(
      '[RoomEntryPage] _joinRoom: 開始 roomId=$roomIdText, displayName=$nameText',
    );

    if (roomIdText.isEmpty || nameText.isEmpty) {
      debugPrint('[RoomEntryPage] バリデーションエラー: 入力が空です');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ルームIDと表示名を入力してください')),
        );
      }
      return;
    }

    if (ref.read(loadingProvider)) return;
    ref.read(loadingProvider.notifier).show();

    try {
      debugPrint('[RoomEntryPage] joinRoom呼び出し開始');
      await ref.read(participantRepositoryProvider).joinRoom(
            roomId: roomIdText,
            displayName: nameText,
          );
      debugPrint('[RoomEntryPage] joinRoom成功');
      if (mounted) {
        context.go('/waiting_room/$roomIdText');
      }
    } catch (e, stackTrace) {
      debugPrint('[RoomEntryPage] joinRoomエラー: $e');
      debugPrint('[RoomEntryPage] スタックトレース: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('参加に失敗しました: $e')),
        );
      }
    } finally {
      ref.read(loadingProvider.notifier).hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      body: Background(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ルームに参加',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ルームIDを入力して参加します。',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    key: const Key('roomIdField'),
                    controller: _roomIdController,
                    decoration: const InputDecoration(
                      labelText: 'ルームID',
                      hintText: '例：abcd1234',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('displayNameField'),
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: '表示名',
                      hintText: 'あなたの名前',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    key: const Key('joinButton'),
                    onPressed: isLoading ? null : _joinRoom,
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text('参加中...'),
                            ],
                          )
                        : const Text('ルームに参加'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
