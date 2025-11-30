import 'dart:math';

/// アイコンセットからランダムにアイコンを選択するユーティリティ
class IconSelector {
  /// 利用可能なアイコンのリスト
  static const List<String> _availableIcons = [
    'assets/icon_set/Apple.png',
    'assets/icon_set/Bear.png',
    'assets/icon_set/Cat.png',
    'assets/icon_set/Dog.png',
    'assets/icon_set/Flog.png',
    'assets/icon_set/Grape.png',
    'assets/icon_set/Meron.png',
    'assets/icon_set/Orange.png',
    'assets/icon_set/image 14.png',
    'assets/icon_set/image 15.png',
  ];

  /// ランダムにアイコンを選択して返す
  static String selectRandomIcon() {
    final random = Random();
    final index = random.nextInt(_availableIcons.length);
    return _availableIcons[index];
  }
}

