import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryEmerald = Color(0xFF1B5E20);
  static const Color darkEmerald = Color(0xFF0D3D12);
  static const Color accentGold = Color(0xFFC5A059);
  static const Color softGold = Color(0xFFE4CF9B);
  static const Color warmBeige = Color(0xFFFFFDF5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFFE0E0E0);
  static const Color textGrey = Color(0xFF616161); // Darkened for accessibility

  // Spacing System (8 / 12 / 16 / 24)
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryEmerald,
        primary: primaryEmerald,
        secondary: accentGold,
        surface: warmBeige,
        onSurface: textDark,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: warmBeige,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'UthmanTaha',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentGold.withValues(alpha: 0.1), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: accentGold.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(color: Colors.white70),
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: const TextStyle(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: textDark),
        bodyMedium: const TextStyle(color: textDark),
      ),
    );
  }

  // Custom Ornament Shapes & Colors
  static const double ornamentOpacityMedium = 0.15;
  static const double ornamentOpacityLight = 0.05;
}
