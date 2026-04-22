import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTheme {
  // Colors
  static const Color primaryGreen = Color(0xFF1B5E20);
  static const Color secondaryGreen = Color(0xFF0D3311);
  static const Color backgroundDark = Color(0xFF051105);
  static const Color tableBorder = Colors.white10;
  static const Color accentAmber = Colors.amber;
  static const Color cardShadow = Colors.black45;
  static const Color overlayBlack = Colors.black38;
  static const Color cardBackBlue = Color(0xFF0D47A1);
  static const Color playerBlue = Colors.blueAccent;
  static const Color aiRed = Colors.redAccent;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: accentAmber,
      ),
    );
  }

  static const BoxDecoration tableGradient = BoxDecoration(
    gradient: RadialGradient(
      colors: [primaryGreen, secondaryGreen, backgroundDark],
      center: Alignment.center,
      radius: 1.5,
    ),
  );
}
