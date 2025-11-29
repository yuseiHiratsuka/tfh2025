import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tfh2025/components/background.dart';
import 'package:tfh2025/utils/mock_data_seeder.dart';

class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const mockRoomId = 'mock_room_001';
                  try {
                    // ボタン無効化などの処理は省略（開発用のため）
                    await ref
                        .read(mockDataSeederProvider)
                        .seedMockData(mockRoomId);
                    if (context.mounted) {
                      context.go('/final_result/$mockRoomId');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('モックデータ作成失敗: $e')),
                      );
                    }
                  }
                },
                child: const Text('Result (Dev)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
