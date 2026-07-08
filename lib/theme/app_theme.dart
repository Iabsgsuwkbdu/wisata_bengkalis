import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Color Palette
  static const Color primaryBlue = Color(0xFF0B63E5);
  static const Color secondaryTurquoise = Color(0xFF00D1FF);
  static const Color tertiarySand = Color(0xFFF3C68F);
  
  static const Color lightBg = Color(0xFFF6F9FD);
  static const Color darkBg = Color(0xFF0A0F1D);
  static const Color darkCardBg = Color(0xFF161E31);

  // Light Scheme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryTurquoise,
      tertiary: tertiarySand,
      background: lightBg,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Color(0xFF1E293B),
      onSurface: Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: lightBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF1E293B)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
    ),
  );

  // Dark Scheme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryTurquoise,
      tertiary: tertiarySand,
      background: darkBg,
      surface: darkCardBg,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFFE2E8F0),
      onSurface: Color(0xFFE2E8F0),
    ),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE2E8F0),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
      titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: darkCardBg,
    ),
  );
}
