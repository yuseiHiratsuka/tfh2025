import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tfh2025/components/background.dart';

class GameStartPage extends StatelessWidget {
  const GameStartPage({
    required this.roomId,
    super.key,
  });

  final String roomId;

  final color = const Color(0xFFE0F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ゲームスタート！',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'みゃくラック',
                style: TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/canvas'),
                child: const Text('キャンパス画面へ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
