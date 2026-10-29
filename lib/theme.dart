import 'package:flutter/material.dart';

/// 디자인 가이드 3장 "색 · 글자" 토큰.
class NwColors {
  static const background = Color(0xFF14121A);
  static const surface = Color(0xFF1E1B26);
  static const surfaceHigh = Color(0xFF292533);
  static const accent = Color(0xFFFFB547); // 결정 버튼 · 취향 일치 강조
  static const accentSoft = Color(0x33FFB547);
  static const textPrimary = Color(0xFFF4F1F8);
  static const textSecondary = Color(0xFFB4ADC2);
  static const good = Color(0xFF7BD389);
  static const soso = Color(0xFFE0C36A);
  static const bad = Color(0xFFE88A8A);
  static const error = Color(0xFFFF8A80);
}

/// 폰 / 넓은 화면을 나누는 기준 (디자인 가이드 4장 적응형).
class Breakpoints {
  static const double wide = 840;
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: NwColors.accent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: NwColors.accent,
    onPrimary: const Color(0xFF2A1A00),
    surface: NwColors.surface,
    error: NwColors.error,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: NwColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: NwColors.background,
      foregroundColor: NwColors.textPrimary,
      centerTitle: false,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: NwColors.textPrimary),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: NwColors.textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: NwColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: NwColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: NwColors.textSecondary),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );
}
