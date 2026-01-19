import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors ---
  static const Color primaryGreen = Color(0xFF4ADE80);
  static const Color primaryBlue = Color(0xFF4D96FF); // Keeping original blue seed
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentYellow = Color(0xFFFDE047);

  // Light Mode Colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E293B); // Slate 800
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color lightBorder = Color(0xFFF1F5F9); // Slate 100

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkBorder = Color(0xFF334155); // Slate 700


  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: lightSurface,
        primary: primaryGreen,
        secondary: primaryBlue,
        onSurface: lightTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(24),
           side: const BorderSide(color: lightBorder),
        ),
      ),
      dividerColor: lightBorder,
      iconTheme: const IconThemeData(color: lightTextSecondary),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        surface: darkSurface,
        primary: primaryGreen,
        secondary: primaryBlue,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
       appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground, // Or darkSurface
        foregroundColor: darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(24),
           side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerColor: darkBorder,
      iconTheme: const IconThemeData(color: darkTextSecondary),
    );
  }
}
