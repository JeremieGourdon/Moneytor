import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color slateGray = Color(0xFF71717A);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color borderGray = Color(0xFFE4E4E7);
  static const Color surfaceGray = Color(0xFFF5F5F5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: black,
        onPrimary: white,
        surface: white,
        onSurface: black,
        error: errorRed,
        onError: white,
        outline: borderGray,
      ),
      scaffoldBackgroundColor: white,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.jetBrainsMono(
          color: black,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.jetBrainsMono(
          color: black,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.jetBrainsMono(
          color: black,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.jetBrainsMono(
          color: black,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          color: black,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderGray, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderGray,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: black,
        unselectedItemColor: slateGray,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
