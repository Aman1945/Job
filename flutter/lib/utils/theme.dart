import 'package:flutter/material.dart';

class NexusTheme {
  // Brand Blue Palette (Core)
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryBlueDark = Color(0xFF1565C0);
  static const Color primaryBlueLight = Color(0xFFBBDEFB);

  // Blue Palette Aliases
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = primaryBlue;
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue900 = Color(0xFF1E3A8A);

  // Modern Neutral Palette (Slate)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Gray Aliases (Mapping to Slate for a modern look)
  static const Color gray50 = slate50;
  static const Color gray100 = slate100;
  static const Color gray200 = slate200;
  static const Color gray300 = slate300;
  static const Color gray400 = slate400;
  static const Color gray500 = slate500;
  static const Color gray600 = slate600;
  static const Color gray700 = slate700;
  static const Color gray800 = slate800;
  static const Color gray900 = slate900;

  // Indigo Palette (Accents)
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo900 = Color(0xFF312E81);

  // Emerald Palette (Success)
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald950 = Color(0xFF022C22);

  // Amber Palette (Warning)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber900 = Color(0xFF78350F);

  // Rose Palette (Error)
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose300 = Color(0xFFFDA4AF);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);
  static const Color rose800 = Color(0xFF9F1239);
  static const Color rose900 = Color(0xFF881337);

  // Purple Palette
  static const Color purple50 = Color(0xFFFAF5FF);
  static const Color purple100 = Color(0xFFF3E8FF);
  static const Color purple200 = Color(0xFFE9D5FF);
  static const Color purple300 = Color(0xFFD8B4FE);
  static const Color purple400 = Color(0xFFC084FC);
  static const Color purple500 = Color(0xFFA855F7);
  static const Color purple600 = Color(0xFF9333EA);
  static const Color purple700 = Color(0xFF7E22CE);
  static const Color purple800 = Color(0xFF6B21A8);
  static const Color purple900 = Color(0xFF581C87);

  // Status Colors (Named Aliases)
  static const Color success = emerald500;
  static const Color warning = amber500;
  static const Color error = rose600;
  static const Color info = indigo500;

  // Surface Colors
  static const Color cardShadow = Color(0x0A000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: const Color(0xFF6366F1),
        surface: Colors.white,
        surfaceVariant: slate50,
      ),
      scaffoldBackgroundColor: slate50,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: slate900,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x1F000000), width: 1), 
        ),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: slate900, letterSpacing: -1),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: slate900, letterSpacing: -0.5),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: slate900),
        bodyLarge: TextStyle(fontSize: 16, color: slate800),
        bodyMedium: TextStyle(fontSize: 14, color: slate600),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: slate500, letterSpacing: 1),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: const Color(0xFF818CF8),
        surface: slate900,
        surfaceVariant: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: slate800, width: 1),
        ),
        color: slate900,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
