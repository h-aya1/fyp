import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors (Extracted from Lottie Animation) ---
  static const Color primaryBlue = Color(0xFF0096C7); // Main Brand Color
  static const Color deepBlue = Color(0xFF033E8A);    // Dark Theme Background Base
  static const Color secondaryCyan = Color(0xFF48CAE3); // Accents
  static const Color accentYellow = Color(0xFFFFDE03); // Highlights

  static const Color primaryGreen = Color(0xFF4ADE80); // Keeping as backup/success color

  // Light Mode Colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF033E8A); // Deep Blue for primary text
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF021835); // Very Dark Navy (derived from Deep Blue)
  static const Color darkSurface = Color(0xFF033E8A);    // Deep Blue as surface
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF90E0EF); // Light Cyan for secondary text
  static const Color darkBorder = Color(0xFF1E40AF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: lightSurface,
        primary: primaryBlue,
        secondary: secondaryCyan,
        tertiary: accentYellow,
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
      iconTheme: const IconThemeData(color: primaryBlue),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: deepBlue,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepBlue,
        brightness: Brightness.dark,
        surface: darkSurface,
        primary: secondaryCyan, // Cyan pops on dark blue
        secondary: accentYellow,
        tertiary: primaryGreen,
        onSurface: darkTextPrimary,
        background: darkBackground,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
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
      iconTheme: const IconThemeData(color: secondaryCyan),
    );
  }
}
