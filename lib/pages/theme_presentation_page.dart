import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ThemePresentationPage extends StatelessWidget {
  const ThemePresentationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('お題提示画面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/game_start'),
              child: const Text('ゲーム開始画面へ'),
            ),
          ],
        ),
      ),
    );
  }
}
