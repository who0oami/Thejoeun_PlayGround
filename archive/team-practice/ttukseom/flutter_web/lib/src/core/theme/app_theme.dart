import 'package:flutter/material.dart';

import 'dashboard_palette.dart';

class AppTheme {
  static ThemeData light() {
    final palette = DashboardPalette.light();
    return _buildTheme(
      brightness: Brightness.light,
      palette: palette,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accentBlue,
        brightness: Brightness.light,
      ).copyWith(
        primary: palette.accentBlue,
        secondary: palette.accentCyan,
        surface: palette.cardBackground,
      ),
    );
  }

  static ThemeData dark() {
    final palette = DashboardPalette.dark();
    return _buildTheme(
      brightness: Brightness.dark,
      palette: palette,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accentCyan,
        brightness: Brightness.dark,
      ).copyWith(
        primary: palette.accentCyan,
        secondary: palette.accentBlue,
        surface: palette.cardBackground,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required DashboardPalette palette,
    required ColorScheme colorScheme,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.pageBackground,
      extensions: [palette],
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: palette.primaryText,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: palette.primaryText,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: palette.primaryText,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: palette.secondaryText,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: palette.secondaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: palette.mutedText,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? palette.selectedItemBackground : const Color(0xFFE9F0FF),
          foregroundColor: isDark ? palette.accentCyan : palette.accentBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: palette.mutedText,
          fontSize: 14,
        ),
        prefixIconColor: palette.mutedText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      dividerColor: palette.cardBorder,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
