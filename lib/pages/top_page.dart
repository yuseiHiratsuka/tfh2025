import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tfh2025/components/background.dart';

class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'みゃくラック',
                      style: TextStyle(fontSize: 64, color: Colors.white),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'スタート→ゴールを、\nAI判定つき絵しりとりでつなごう！',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.go('/room_entry'),
                child: const Text('はじめる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
