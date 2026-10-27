import 'package:flutter/material.dart';

/// Palet warna Saku — Neo-Brutalism.
class AppColors {
  AppColors._();

  static const brand = Color(0xFFFF3B57);
  static const brandDeep = Color(0xFFE71D36);
  static const violet = Color(0xFF7C3FFF);
  static const accent = Color(0xFF22D3EE);
  static const income = Color(0xFF22C55E);
  static const expense = Color(0xFFFF3B57);
  static const warning = Color(0xFFFFD93B);

  // Neo-Brutalism base
  static const lightBg = Color(0xFFFFF7ED);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);

  // Neo-Brutalism dark
  static const darkBg = Color(0xFF151515);
  static const darkSurface = Color(0xFF1F1F1F);
  static const darkCard = Color(0xFF1F1F1F);
  static const darkElevated = Color(0xFF262626);

  // Solid shadows
  static const shadowBlack = Color(0xFF000000);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF3B57), Color(0xFFFF6B6B)],
  );

  static const scanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22D3EE), Color(0xFF3B82FF)],
  );
}
