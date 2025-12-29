import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Palette
  static const Color primaryGreen = Color(0xFF1C9C07);
  static const Color darkGreen = Color(0xFF0F553D);
  static const Color accentGold = Color(0xFFC9A227);
  
  // Light Mode Colors
  static const Color lightSurface = Color(0xFFF4F6F8);
  static const Color lightText = Color(0xFF1F2937);
  
  // Dark Mode Colors
  static const Color darkSurface = Color(0xFF121212); // Deep Black/Grey
  static const Color darkCard = Color(0xFF1E1E1E);    // Slightly lighter for cards
  static const Color darkText = Color(0xFFE0E0E0);

  // ================= LIGHT THEME =================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightSurface,
    
    // Typography
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: lightText),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: lightText),
      bodyLarge: GoogleFonts.poppins(color: lightText),
      bodyMedium: GoogleFonts.poppins(color: Color(0xFF6B7280)),
    ),

    // App Bar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: accentGold,
      surface: Colors.white,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    
    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
  );

  // ================= DARK THEME =================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkSurface,
    
    // Typography (Light text on Dark bg)
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: darkText),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: darkText),
      bodyLarge: GoogleFonts.poppins(color: darkText),
      bodyMedium: GoogleFonts.poppins(color: Colors.white70),
    ),

    // App Bar (Darker Green)
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGreen, // Darker green for dark mode
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: accentGold,
      surface: darkCard,
    ),

    // Card Theme (Dark Grey Cards)
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Input Fields (Dark Grey with Light Text)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryGreen)),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    
     // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),
  );
}