import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color.fromRGBO(28, 156, 7, 1.0);
  static const Color secondaryGreen = Color(0xFF0F766E);
  static const Color accentGold = Color(0xFFC9A227);
  static const Color background = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
    ),

    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textSecondary),
      titleLarge: TextStyle(color: textPrimary),
    ),
  );
}
