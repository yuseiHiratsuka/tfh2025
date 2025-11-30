import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

final loadingProvider = NotifierProvider<LoadingNotifier, bool>(() {
  return LoadingNotifier();
});
