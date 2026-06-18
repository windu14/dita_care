import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors: Dark Pastel Pink and Dark Pastel Green
  static const Color darkPastelPink = Color(0xFFB57E8C);
  static const Color darkPastelGreen = Color(0xFF7D9C8D);
  static const Color backgroundLight = Color(0xFFF9F6F7);
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textLight = Color(0xFF757575);

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(color: textDark, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.spaceGrotesk(color: textDark, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.spaceGrotesk(color: textDark, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.spaceGrotesk(color: textDark),
      bodyMedium: GoogleFonts.spaceGrotesk(color: textDark),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPastelPink,
        primary: darkPastelPink,
        secondary: darkPastelGreen,
        surface: surfaceColor,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: darkPastelPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPastelPink,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: darkPastelGreen,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: darkPastelPink, width: 2),
        ),
      ),
    );
  }
}
