import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tfh2025/components/background.dart';

class GameStartPage extends StatelessWidget {
  const GameStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'みゃくラック',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('キャンパス画面へ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
