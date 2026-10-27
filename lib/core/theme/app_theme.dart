import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema aplikasi Saku — Material 3, bersih, dan modern.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.violet,
      onSecondary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: const Color(0xFF111111),
      onSurfaceVariant: const Color(0xFF333333),
      outline: const Color(0xFF000000),
      outlineVariant: const Color(0xFF000000),
      error: AppColors.expense,
    ),
    AppColors.lightBg,
    Brightness.light,
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.violet,
      surface: AppColors.darkSurface,
      onSurface: const Color(0xFFFFFFFF),
      onSurfaceVariant: const Color(0xFFDADADA),
      outline: const Color(0xFFFFFFFF),
      outlineVariant: const Color(0xFFFFFFFF),
      error: AppColors.expense,
    ),
    AppColors.darkBg,
    Brightness.dark,
  );

  static ThemeData _build(
    ColorScheme scheme,
    Color background,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      splashColor: scheme.primary.withValues(alpha: 0.06),
      highlightColor: scheme.primary.withValues(alpha: 0.03),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: _inputBorder(Colors.transparent, 0),
        enabledBorder: _inputBorder(Colors.transparent, 0),
        focusedBorder: _inputBorder(scheme.primary.withValues(alpha: 0.6), 1),
        errorBorder: _inputBorder(scheme.error.withValues(alpha: 0.8), 1),
        focusedErrorBorder: _inputBorder(scheme.error, 1),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brand.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: scheme.onSurface,
          side: const BorderSide(color: Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          highlightColor: scheme.primary.withValues(alpha: 0.08),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        contentTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        actionTextColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 3),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.brand.withValues(alpha: 0.18),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2.5),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? scheme.primary : scheme.onSurface,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: isDark ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 3),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 3),
        ),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.1,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white : Colors.black,
        thickness: 2,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 6,
        ),
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.white : Colors.black, width: 2.5),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static InputBorder _neoBorder(Color color, {double width = 3}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
