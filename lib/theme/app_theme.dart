import 'package:flutter/material.dart';

/// ベースカラーをまとめておくことで配色の差し替えをしやすくする。
class AppColors {
  static const Color primary = Color.fromRGBO(174, 174, 29, 1);
  static const Color secondary = Color.fromRGBO(245, 158, 11, 1);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color error = Color(0xFFDC2626);
  static const Color onSurfaceLight = Color(0xFF1F2937); // ライトモード用（暗いグレー）
  static const Color onSurfaceDark = Colors.white; // ダークモード用（白）
  static const Color backgroundStart = Color(0xFFCF00A9);
  static const Color backgroundEnd = Color(0xFF00BCD9);
}

class AppTheme {
  /// Light/Dark それぞれの ColorScheme を明示しておくと調整が楽。
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceLight,
    error: AppColors.error,
    onSurface: AppColors.onSurfaceLight,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceDark,
    error: AppColors.error,
    onSurface: AppColors.onSurfaceDark,
  );

  static final ThemeData light = _theme(lightColorScheme);
  static final ThemeData dark = _theme(darkColorScheme);

  static ThemeData _theme(ColorScheme scheme) {
    final textTheme = scheme.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      textTheme: textTheme.apply(
        displayColor: scheme.onSurface,
        bodyColor: scheme.onSurface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
