import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home_page_controller.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    final fadeAnimation = useAnimation(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.elasticOut),
      ),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.8),
              colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // タイトルロゴ
                    Opacity(
                      opacity: fadeAnimation,
                      child: Transform.scale(
                        scale: scaleAnimation,
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_esports_rounded,
                              size: 120,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'TFH 2025',
                              style: textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ゲームを楽しもう',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // メインボタン群
                    Opacity(
                      opacity: fadeAnimation,
                      child: Column(
                        children: [
                          // ゲーム開始ボタン
                          SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(homePageControllerProvider.notifier)
                                    .startGame();
                                // TODO: ゲーム画面へ遷移
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 4,
                                shadowColor: colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'ゲーム開始',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // サブボタン
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(
                                            homePageControllerProvider.notifier,
                                          )
                                          .openSettings();
                                    },
                                    icon: const Icon(Icons.settings_rounded),
                                    label: const Text('設定'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // TODO: ランキング画面へ
                                    },
                                    icon: const Icon(Icons.leaderboard_rounded),
                                    label: const Text('ランキング'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ヘルプボタン
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: ヘルプ画面へ
                              },
                              icon: const Icon(Icons.help_outline_rounded),
                              label: const Text('遊び方'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                side: BorderSide(
                                  color: colorScheme.outline,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // フッター
                    Opacity(
                      opacity: fadeAnimation * 0.6,
                      child: Text(
                        '© 2025 TFH',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
