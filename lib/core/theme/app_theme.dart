import 'package:flutter/material.dart';

import '../constants/pharos_layout.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final ColorScheme colorScheme = const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.text,
      secondary: AppColors.surface,
      onSecondary: AppColors.text,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: Color(0xFFCF6679),
      onError: AppColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: TextStyle(color: AppColors.text.withOpacity(0.55)),
        contentPadding: const EdgeInsets.symmetric(horizontal: PharosLayout.spaceMd, vertical: PharosLayout.spaceSm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
          borderSide: BorderSide(color: AppColors.black.withOpacity(0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
          borderSide: BorderSide(color: AppColors.black.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharosLayout.radiusMd),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.black.withOpacity(0.35)),
        ),
      ),
      dividerTheme: DividerThemeData(color: AppColors.text.withOpacity(0.12)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.accent,
        contentTextStyle: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.text),
        bodyMedium: TextStyle(color: AppColors.text),
        bodySmall: TextStyle(color: AppColors.text),
        titleLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.text),
      ),
    );
  }
}
