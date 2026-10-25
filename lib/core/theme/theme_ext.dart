import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Helper warna & teks yang mengikuti tema aktif.
extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  ColorScheme get scheme => Theme.of(this).colorScheme;

  Color get cardColor => isDark ? AppColors.darkCard : Colors.white;

  Color get borderColor =>
      isDark ? const Color(0xFF242738) : const Color(0xFFECEEF6);

  Color get mutedColor => isDark
      ? const Color(0xFF8E95A9)
      : const Color(0xFF7C8396);

  Color get faintColor =>
      isDark ? const Color(0xFF1C1F2C) : const Color(0xFFF2F3F9);

  Color get inputFillColor => isDark ? AppColors.darkCard : Colors.white;

  TextTheme get texts => Theme.of(this).textTheme;
}
