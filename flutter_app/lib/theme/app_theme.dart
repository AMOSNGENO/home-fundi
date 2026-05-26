import 'package:flutter/material.dart';

class AppTheme {
  static const Color canvas = Color(0xFFF7FBF4);
  static const Color ink = Color(0xFF083F2B);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFE5362D);
  static const Color leaf = Color(0xFF149447);
  static const Color coral = Color(0xFFFF6F61);
  static const Color sky = Color(0xFFE7F7EF);
  static const Color danger = Color(0xFFE5362D);
  static const Color success = Color(0xFF149447);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: false);

    return base.copyWith(
      primaryColor: ink,
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.light(
        primary: ink,
        secondary: accent,
        tertiary: leaf,
        surface: paper,
        onPrimary: paper,
        onSecondary: ink,
        onSurface: ink,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ink,
        foregroundColor: paper,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: paper,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: ink,
          height: 0.95,
        ),
        headlineLarge: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: ink,
          height: 1.0,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: ink,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
          height: 1.35,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ink,
          height: 1.35,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: ink,
          letterSpacing: 0.6,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: paper,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: ink, width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          backgroundColor: paper,
          side: const BorderSide(color: ink, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
          borderSide: const BorderSide(color: ink, width: 3),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: 3),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ink, width: 3),
        ),
        labelStyle: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: TextStyle(
          color: ink.withValues(alpha: 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        color: paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: ink, width: 3),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: ink,
        thickness: 3,
        space: 24,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: accent,
        labelStyle: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w900,
        ),
        side: const BorderSide(color: ink, width: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
