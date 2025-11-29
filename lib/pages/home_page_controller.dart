import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_page_controller.freezed.dart';
part 'home_page_controller.g.dart';

@riverpod
class HomePageController extends _$HomePageController {
  @override
  HomePageState build() {
    return const HomePageState();
  }

  void startGame() {
    // ゲーム開始処理
    state = state.copyWith(isStarting: true);
  }

  void openSettings() {
    state = state.copyWith(showSettings: true);
  }

  void closeSettings() {
    state = state.copyWith(showSettings: false);
  }
}

@freezed
abstract class HomePageState with _$HomePageState {
  const factory HomePageState({
    @Default(false) bool isStarting,
    @Default(false) bool showSettings,
  }) = _HomePageState;

  factory HomePageState.fromJson(Map<String, Object?> json) =>
      _$HomePageStateFromJson(json);
}
