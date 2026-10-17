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
}
