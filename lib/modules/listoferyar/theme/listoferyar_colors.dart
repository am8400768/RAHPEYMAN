import 'package:flutter/material.dart';

/// رنگ‌ها و نقش‌های بصری اختصاصی لیستوفر‌یار.
/// مقادیر بر پایه هویت بصری اصلی رهپیمان تنظیم شده‌اند و عمداً
/// Palette مستقل و بی‌ارتباط با RAHPEYMAN ایجاد نشده است.
abstract final class ListoferyarColors {
  // Brand / RahPeyman
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color accent = Color(0xFF00BFA5);
  static const Color textDark = Color(0xFF1A237E);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF2E7D32);

  // Secondary surfaces
  static const Color surfaceSoft = Color(0xFFF8FAFD);
  static const Color surfaceBlue = Color(0xFFEAF2FB);
  static const Color surfaceTeal = Color(0xFFE7F8F5);

  // Borders / dividers
  static const Color border = Color(0xFFDCE5EF);
  static const Color borderSoft = Color(0xFFE8EEF5);
  static const Color divider = Color(0xFFD7E0EA);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF52627A);
  static const Color textMuted = Color(0xFF78879A);
  static const Color textOnPrimary = Colors.white;

  // Semantic states
  static const Color info = Color(0xFF1976D2);
  static const Color warning = Color(0xFFE58A00);
  static const Color danger = Color(0xFFC62828);

  // Focus / interaction
  static const Color focus = Color(0xFF00BFA5);
  static const Color selection = Color(0x1F00BFA5);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: <Color>[
      Color(0xFF0D47A1),
      Color(0xFF1976D2),
    ],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: <Color>[
      Color(0xFF0D47A1),
      Color(0xFF1976D2),
      Color(0xFF00BFA5),
    ],
  );
}
