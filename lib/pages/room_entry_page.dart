import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/components/background.dart';

class RoomEntryPage extends ConsumerStatefulWidget {
  const RoomEntryPage({super.key});

  @override
  ConsumerState<RoomEntryPage> createState() => _RoomEntryPageState();
}

class _RoomEntryPageState extends ConsumerState<RoomEntryPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Background(
        scrollable: true,
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
            Text(
              '新しいルームを作成します。',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/password?create=true'),
              child: const Text('「新しいルーム」を作成'),
            ),
            const SizedBox(height: 40),
            Text(
              '「あいことば」\nを入力',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              '「あいことば」を入力して友達と一緒に\nゲームを楽しめます。',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/password'),
              child: const Text('「あいことば」を入力'),
            ),
          ],
        ),
      ),
    );
  }
}
