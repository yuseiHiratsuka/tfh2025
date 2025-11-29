import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JudgingPage extends StatelessWidget {
  const JudgingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('判定中画面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/final_result'),
              child: const Text('最終結果画面へ'),
            ),
          ],
        ),
      ),
    );
  }
}
