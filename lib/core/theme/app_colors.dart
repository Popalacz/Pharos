import 'package:flutter/material.dart';

/// Pharos store palette (BO-style greys + bronze accent).
abstract final class AppColors {
  static const Color text = Color(0xFFFFFFFF);
  static const Color background = Color(0xFF1B1B1B);
  static const Color surface = Color(0xFF484C50);
  static const Color accent = Color(0xFF80410E);

  /// Accent for text and icons (>= 4.5:1 on background and surface). `accent` stays a fill colour.
  static const Color accentText = Color(0xFFF0B07A);
  static const Color black = Color(0xFF000000);

  /// Text on dark surfaces: secondary (white 70%), muted, disabled.
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0x62FFFFFF);

  /// Outlines and dividers (white 24% and 10%).
  static const Color border = Color(0x3DFFFFFF);
  static const Color divider = Color(0x1AFFFFFF);

  /// Status colours, all >= 4.5:1 on background.
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);

  /// Fill for destructive buttons (white text >= 4.5:1). Use `error` for text, icons and borders.
  static const Color errorFill = Color(0xFFC62828);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF64B5F6);
}
