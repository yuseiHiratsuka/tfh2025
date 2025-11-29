import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GameStartPage extends StatelessWidget {
  const GameStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ゲーム開始画面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/canvas'),
              child: const Text('キャンパス画面へ'),
            ),
          ],
        ),
      ),
    );
  }
}
