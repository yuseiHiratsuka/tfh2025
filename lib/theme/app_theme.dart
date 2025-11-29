import 'package:flutter/material.dart';

/// ベースカラーをまとめておくことで配色の差し替えをしやすくする。
class AppColors {
  static const Color primary = Color(0xFFCF00A9);
  static const Color secondary = Color(0xFF00BCD9);
  static const Color surfaceLight = Colors.white;
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color error = Color(0xFFDC2626);
  static const Color onSurfaceLight = Color(0xFF1F2937); // ライトモード用（暗いグレー）
  static const Color onSurfaceDark = Colors.white; // ダークモード用（白）
  static const Color shadow = Color(0xFF301A6B);
  static const Color surfaceContainer = Color(0xFF002E80);
  static const Color textBody = Colors.white;
  static const Color onSurfaceVariant = Colors.white;
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
    shadow: AppColors.shadow,
    surfaceContainer: AppColors.surfaceContainer,
    onSurfaceVariant: AppColors.onSurfaceVariant,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceDark,
    error: AppColors.error,
    onSurface: AppColors.onSurfaceDark,
    shadow: AppColors.shadow,
    surfaceContainer: AppColors.surfaceContainer,
    onSurfaceVariant: AppColors.onSurfaceVariant,
  );

  static final ThemeData light = _theme(lightColorScheme);
  static final ThemeData dark = _theme(darkColorScheme);

  static ThemeData _theme(ColorScheme scheme) {
    final baseTextTheme = scheme.brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;

    final textTheme = baseTextTheme.copyWith(
      titleMedium: const TextStyle(fontSize: 48),
      bodyLarge: const TextStyle(fontSize: 28),
      bodyMedium: const TextStyle(fontSize: 20),
    );

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
        displayColor: AppColors.textBody,
        bodyColor: AppColors.textBody,
        fontFamily: 'NicomojiPlus',
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.shadow,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          shape: StadiumBorder(
            side: BorderSide(width: 3, color: scheme.shadow),
          ),
          textStyle: const TextStyle(
            fontSize: 24,
            fontFamily: 'NicomojiPlus',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 22,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
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
