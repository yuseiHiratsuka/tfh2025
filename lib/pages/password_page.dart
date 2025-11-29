import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/providers/loading_provider.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

class PasswordPage extends ConsumerStatefulWidget {
  const PasswordPage({super.key});
  @override
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController(text: 'L7qqB8lctYU9niXqOKOT');
    _displayNameController = TextEditingController(
      text: 'プレイヤー${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ルームIDと表示名を入力してください')),
        );
      }
      return;
    }

    ref.read(loadingProvider.notifier).show();

    try {
      debugPrint('[RoomEntryPage] joinRoom呼び出し開始');
      await ref.read(participantRepositoryProvider).joinRoom(
            roomId: roomIdText,
            displayName: nameText,
          );
      debugPrint('[RoomEntryPage] joinRoom成功');
      if (mounted) {
        // 待機画面へ遷移
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

    return Scaffold(
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '「あいことば」\nを入力',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '入力した「あいことば」のルームに\n参加します。',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextFormField(
              decoration: const InputDecoration(
                hintText: '例：うめこぶちゃ',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ref.read(loadingProvider) ? null : _joinRoom();
              },
              child: const Text('ルームに参加'),
            ),
          ],
        ),
      ),
    );
  }
}
