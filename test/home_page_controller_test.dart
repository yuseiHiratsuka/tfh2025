import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import 'package:tfh2025/pages/home_page_controller.dart';

void main() {
  group('HomePageController', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態はisStarting=false/showSettings=false', () {
      final state = container.read(homePageControllerProvider);

      expect(state.isStarting, isFalse);
      expect(state.showSettings, isFalse);
    });

    test('startGameと設定表示のトグルが状態を上書きする', () {
      final subscription = container.listen<HomePageState>(
        homePageControllerProvider,
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final controller = container.read(homePageControllerProvider.notifier);

      controller.startGame();
      expect(subscription.read().isStarting, isTrue);

      // startGameを重ねて呼んでも最後の状態が維持される
      controller.startGame();
      expect(subscription.read().isStarting, isTrue);

      controller.openSettings();
      expect(subscription.read().showSettings, isTrue);

      controller.closeSettings();
      expect(subscription.read().showSettings, isFalse);

      // open/closeの連続呼び出しでも直近の指示が反映される
      controller.openSettings();
      controller.closeSettings();
      expect(subscription.read().showSettings, isFalse);

      controller.openSettings();
      expect(subscription.read().showSettings, isTrue);
    });
  });
}
