import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color background = Color(0xFFFFFDF1);
  static const Color peach = Color(0xFFFFCE99);
  static const Color primaryOrange = Color(0xFFFF9644);
  static const Color darkBrown = Color(0xFF562F00);

  // For backward compatibility during migration
  static const Color primaryPurple = primaryOrange;

  static ThemeData theme = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: background,
    primaryColor: primaryOrange,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryOrange,
      primary: primaryOrange,
      secondary: peach,
      surface: background,
      onPrimary: Colors.white,
      onSurface: darkBrown,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: darkBrown),
      bodyMedium: TextStyle(color: darkBrown),
    ),
  );
}
