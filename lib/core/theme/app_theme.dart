import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color accent = Color(0xFF00BFA5);
  static const Color textDark = Color(0xFF1A237E);
  static const Color background = Color(0xFFF5F7FA);
  static const Color success = Color(0xFF2E7D32);
  static const Color surface = Colors.white;

  static const String slogan = 'همراه مهندسین از آموزش تا اجرا';

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Vazirmatn',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'ETHNOCEN',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontFamily: 'IRANSansWeb',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          height: 1.7,
          color: textDark,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
    );
  }
}
