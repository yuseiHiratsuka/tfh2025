import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinalResultPage extends StatelessWidget {
  const FinalResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('最終結果画面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/waiting_room'),
              child: const Text('待機ルームへ'),
            ),
          ],
        ),
      ),
    );
  }
}
