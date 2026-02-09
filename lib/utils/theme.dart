import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexusTheme {
  static const Color emerald950 = Color(0xFF064e3b);
  static const Color emerald900 = Color(0xFF065f46);
  static const Color emerald500 = Color(0xFF10b981);
  static const Color emerald400 = Color(0xFF34d399);
  static const Color emerald300 = Color(0xFF6ee7b7);
  static const Color slate50 = Color(0xFFf8fafc);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate600 = Color(0xFF475569);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: emerald900,
        primary: emerald900,
        secondary: emerald500,
        surface: slate50,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 32),
        bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 14),
        labelLarge: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: slate600),
      ),
      scaffoldBackgroundColor: slate50,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: emerald950,
        primary: emerald500,
        surface: emerald950,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: emerald950,
    );
  }
}
