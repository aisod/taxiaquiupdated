import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary color palette - custom Tax Aqui colors
  static const Color primaryBlue = Color(0xFF1D459D); // Primary color #1D459D
  static const Color secondaryPurple = Color(0xFF3A69DF); // Secondary color #3A69DF
  static const Color tertiaryTeal = Color(0xFF06B6D4); // Teal accent
  
  // Background colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color surfaceColor = Colors.white;
  
  // Text colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Other colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Additional UI colors for compatibility
  static const Color cardBackground = Colors.white;
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color darkBackground = Color(0xFF1E293B);
  static const Color mediumBackground = Color(0xFF334155);
  static const Color lightTextColor = Color(0xFF94A3B8);
  static const Color darkTextColor = Color(0xFF1E293B);
  
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryBlue,
        secondary: secondaryPurple,
        tertiary: tertiaryTeal,
        surface: surfaceColor,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: textDark,
        onError: Colors.white,
        outline: textLight,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          headlineLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
          headlineSmall: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(color: textDark, fontWeight: FontWeight.bold),
          titleMedium: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
          titleSmall: const TextStyle(color: textGrey, fontWeight: FontWeight.w600),
          bodyLarge: const TextStyle(color: textDark),
          bodyMedium: const TextStyle(color: textGrey),
          bodySmall: const TextStyle(color: textLight),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: primaryBlue),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: textLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: textDark,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryBlue,
        secondary: secondaryPurple,
        tertiary: tertiaryTeal,
        surface: const Color(0xFF334155),
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        outline: textLight,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineSmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleSmall: const TextStyle(color: textLight, fontWeight: FontWeight.w600),
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: textLight),
          bodySmall: const TextStyle(color: textGrey),
        ),
      ),
    );
  }
}