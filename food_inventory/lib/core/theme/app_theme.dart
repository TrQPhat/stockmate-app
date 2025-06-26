import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Green color palette
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color accentGreen = Color(0xFF81C784);

  static const Color backgroundColor = Color(0xFFFFFBF5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFF9800);

  // Primary Colors - Food themed
  static const Color primaryOrange = Color(0xFFFF6B35); // Carrot orange
  static const Color accentYellow = Color(0xFFFFC107); // Corn yellow

  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFBF5); // Cream white
  static const Color backgroundDark = Color(0xFF2E2E2E);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningOrange = Color(0xFFFF9800);

  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);

  // Food Category Colors
  static const Map<String, Color> categoryColors = {
    'vegetables': Color(0xFF4CAF50),
    'fruits': Color(0xFFFF5722),
    'meat': Color(0xFF795548),
    'dairy': Color(0xFF2196F3),
    'grains': Color(0xFFFFC107),
    'snacks': Color(0xFF9C27B0),
  };

  // Food Category Icons
  static const Map<String, IconData> categoryIcons = {
    'vegetables': Icons.eco,
    'fruits': Icons.apple,
    'meat': Icons.restaurant,
    'dairy': Icons.local_drink,
    'grains': Icons.grain,
    'snacks': Icons.cookie,
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
