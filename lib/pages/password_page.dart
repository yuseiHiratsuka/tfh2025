import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/providers/loading_provider.dart';
import 'package:tfh2025/services/repositories/auth_repository.dart';
import 'package:tfh2025/services/repositories/participant_repository.dart';
import 'package:tfh2025/services/repositories/room_repository.dart';
import 'package:tfh2025/utils/rive_support.dart';

class PasswordPage extends ConsumerStatefulWidget {
  const PasswordPage({required this.isCreateMode, super.key});

  final bool isCreateMode;

  @override
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
  late final TextEditingController _passwordController;
  late final TextEditingController _displayNameController;
  File? _riveFile;
  RiveWidgetController? _controller;
  bool _riveEnabled = isRiveSupported;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _displayNameController = TextEditingController();
    Future.microtask(
      () => ref.read(authRepositoryProvider).signInAnonymouslyIfNeeded(),
    );
    if (_riveEnabled) {
      _loadRiveFile();
    }
  }

  Future<void> _loadRiveFile() async {
    final riveFile =
        await loadRiveFileIfSupported('assets/rive/happy_meeple.riv');
    if (!mounted) return;
    if (riveFile == null) {
      setState(() {
        _riveEnabled = false;
      });
      return;
    }
    _riveFile = riveFile;
    _controller = RiveWidgetController(_riveFile!);
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final passwordText = _passwordController.text.trim();
    final nameText = _displayNameController.text.trim();
    final mode = widget.isCreateMode ? '作成' : '参加';
    debugPrint(
      '[PasswordPage] _handleSubmit: 開始 mode=$mode, password=$passwordText, displayName=$nameText',
    );

    if (passwordText.isEmpty || nameText.isEmpty) {
      debugPrint('[PasswordPage] バリデーションエラー: 入力が空です');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('合言葉とプレイヤー名を入力してください')),
        );
      }
      return;
    }

    ref.read(loadingProvider.notifier).show();

    try {
      String roomId;

      if (widget.isCreateMode) {
        // 作成モード: 新しいルームを作成
        debugPrint('[PasswordPage] ルーム作成開始');
        final room = await ref.read(roomRepositoryProvider).createRoom(
              password: passwordText,
            );
        debugPrint('[PasswordPage] ルーム作成成功: roomId=${room.id}');
        roomId = room.id;

        // 作成したルームに参加
        debugPrint('[PasswordPage] ルーム参加開始');
        await ref.read(participantRepositoryProvider).joinRoom(
              roomId: roomId,
              displayName: nameText,
            );
        debugPrint('[PasswordPage] ルーム参加成功');
      } else {
        // 参加モード: 既存のルームに参加
        debugPrint('[PasswordPage] joinRoom呼び出し開始');
        await ref.read(participantRepositoryProvider).joinRoom(
              password: passwordText,
              displayName: nameText,
            );
        debugPrint('[PasswordPage] joinRoom成功');

        // 参加したルームのIDを取得するため、Firestoreから取得
        final roomsSnapshot = await FirebaseFirestore.instance
            .collection('rooms')
            .where('password', isEqualTo: passwordText)
            .where('status', isEqualTo: 'waiting')
            .limit(1)
            .get();

        if (roomsSnapshot.docs.isEmpty) {
          throw StateError('ルームが見つかりません');
        }

        roomId = roomsSnapshot.docs.first.id;
        debugPrint('[PasswordPage] ルームID取得成功: roomId=$roomId');
      }

      if (mounted) {
        // 待機画面へ遷移
        context.go('/waiting_room/$roomId?password=$passwordText');
      }
    } catch (e, stackTrace) {
      debugPrint('[PasswordPage] エラー: $e');
      debugPrint('[PasswordPage] スタックトレース: $stackTrace');
      if (mounted) {
        final errorMessage = widget.isCreateMode ? '作成に失敗しました' : '参加に失敗しました';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$errorMessage: $e')),
        );
      }
    } finally {
      ref.read(loadingProvider.notifier).hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = widget.isCreateMode ? '「あいことば」\nを決める' : '「あいことば」\nを入力';
    final description = widget.isCreateMode
        ? '新しいルームを作成します。\n「あいことば」を決めてください。'
        : '入力した「あいことば」のルームに\n参加します。';
    final buttonText = widget.isCreateMode ? 'ルームを作成' : 'ルームに参加';

    return Scaffold(
      body: Background(
        scrollable: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Riveアニメーション
            SizedBox(
              height: 150,
              child: _buildRiveOrFallback(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'プレイヤー名',
                hintText: '例: たろう',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'あいことば',
                hintText: '例: うめこぶちゃ',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ref.read(loadingProvider) ? null : _handleSubmit();
              },
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiveOrFallback() {
    if (_riveEnabled && _controller != null) {
      return RiveWidget(
        controller: _controller!,
      );
    }

    if (_riveEnabled) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Image(
      image: AssetImage('assets/images/robot.png'),
      fit: BoxFit.contain,
    );
  }
}
