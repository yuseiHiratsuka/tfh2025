import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('キャンパス画面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/judging'),
              child: const Text('判定中画面へ'),
            ),
          ],
        ),
      ),
    );
  }
}
