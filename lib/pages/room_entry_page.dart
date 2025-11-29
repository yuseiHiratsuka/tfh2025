import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';

class RoomEntryPage extends ConsumerStatefulWidget {
  const RoomEntryPage({super.key});

  @override
  ConsumerState<RoomEntryPage> createState() => _RoomEntryPageState();
}

class _RoomEntryPageState extends ConsumerState<RoomEntryPage> {
  late final TextEditingController _roomIdController;
  late final TextEditingController _displayNameController;
  bool _isJoining = false;

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

    setState(() {
      _isJoining = true;
    });

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
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Background(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '「新しいルーム」\nを作成',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => context.go('/room_entry'),
              child: const Text('「新しいルーム」を作成'),
            ),

            const SizedBox(height: 24),

            Text(
              '新しいルームを作成します。',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Text(
              '「あいことば」\nを入力',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            Text(
              '「あいことば」を入力して知り合いと一緒に\nゲームを楽しめます。',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => context.go('/password'),
              child: const Text('「あいことば」を入力'),
            ),
            // // タイトル
            // Text(
            //   'ルームに参加',
            //   style: theme.textTheme.titleMedium,
            // ),

            // const SizedBox(height: 40),

            // // ルームID入力
            // Container(
            //   constraints: const BoxConstraints(maxWidth: 400),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.stretch,
            //     children: [
            //       TextField(
            //         controller: _roomIdController,
            //         decoration: const InputDecoration(
            //           labelText: 'ルームID',
            //           hintText: '参加するルームのIDを入力',
            //         ),
            //       ),
            //       const SizedBox(height: 16),

            //       // 表示名入力
            //       TextField(
            //         controller: _displayNameController,
            //         decoration: InputDecoration(
            //           labelText: '表示名',
            //           hintText: 'あなたの名前を入力',
            //           prefixIcon: const Icon(Icons.person),
            //           border: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //           filled: true,
            //           fillColor: theme.colorScheme.surface,
            //         ),
            //       ),
            //       const SizedBox(height: 32),

            //       // 参加ボタン
            //       SizedBox(
            //         height: 56,
            //         child: ElevatedButton.icon(
            //           onPressed: _isJoining ? null : _joinRoom,
            //           icon: _isJoining
            //               ? const SizedBox(
            //                   width: 20,
            //                   height: 20,
            //                   child: CircularProgressIndicator(
            //                     strokeWidth: 2,
            //                   ),
            //                 )
            //               : const Icon(Icons.login),
            //           label: Text(
            //             _isJoining ? '参加中...' : 'ルームに参加',
            //             style: const TextStyle(
            //               fontSize: 18,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           style: ElevatedButton.styleFrom(
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // 戻るボタン
            // TextButton.icon(
            //   onPressed: () => context.go('/top'),
            //   icon: const Icon(Icons.arrow_back),
            //   label: const Text('トップに戻る'),
            // ),
          ],
        ),
      ),
    );
  }
}
