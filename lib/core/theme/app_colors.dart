import 'package:flutter/material.dart';

/// Palet warna Saku.
class AppColors {
  AppColors._();

  static const brand = Color(0xFF5B5BD6);
  static const brandDeep = Color(0xFF4338CA);
  static const violet = Color(0xFF8B5CF6);
  static const accent = Color(0xFF14B8A6);
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFF43F5E);
  static const warning = Color(0xFFF59E0B);

  static const lightBg = Color(0xFFF6F6FB);
  static const darkBg = Color(0xFF0C0D12);
  static const darkCard = Color(0xFF151722);
  static const darkElevated = Color(0xFF1D2030);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D5DFB), Color(0xFF9B4DFF)],
  );

  static const scanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
  );
}
