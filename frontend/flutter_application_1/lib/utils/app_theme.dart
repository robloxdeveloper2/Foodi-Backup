import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color accent = Color(0xFFFF6B35);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFE53E3E);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color divider = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        primaryContainer: primaryLight,
        secondary: accent,
        surface: background,
        onSurface: textPrimary,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          fontFamily: 'Roboto',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Roboto',
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        primaryContainer: primaryDark,
        secondary: accent,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
} 