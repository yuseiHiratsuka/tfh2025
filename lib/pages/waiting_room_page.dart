import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tfh2025/painter.dart';

class WaitingRoomPage extends StatelessWidget {
  const WaitingRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('待機ルーム'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/theme_presentation'),
              child: const Text('お題提示画面へ'),
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }
}
