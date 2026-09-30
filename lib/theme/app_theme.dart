import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color primary = Color(0xFF222222);
  static const Color secondary = Color(0xFF666666);
  static const Color border = Color(0xFFBDBDBD);
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Colors.white;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primary,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(
          color: border,
          width: 0.8,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: primary,
          width: 1.2,
        ),
      ),

      labelStyle: const TextStyle(
        color: secondary,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(
          color: border,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: border,
      thickness: 0.8,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: primary,
      ),
      bodyMedium: TextStyle(
        color: secondary,
      ),
    ),
  );
}