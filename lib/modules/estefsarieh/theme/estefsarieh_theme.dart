import 'package:flutter/material.dart';

/// تم ماژول استفساریه — هماهنگ با Design System رهپیمان (Hierarchical Edition)
/// Primary: #0D47A1 | Accent: #00BFA5
class EstefsariehColors {
  // brand
  static const primary = Color(0xFF0D47A1);
  static const primaryDark = Color(0xFF002171); // Deep End
  static const skyLight = Color(0xFF64B5F6);    // Sky Top
  static const primaryLight = Color(0xFF5472D3);
  
  static const accent = Color(0xFF00BFA5);
  static const accentSoft = Color(0x1A00BFA5);

  // surfaces
  static const bgBase = Color(0xFFF5F7FB);
  static const panel = Color(0xFFFFFFFF);
  static const panel2 = Color(0xFFF0F4FA);
  static const panel3 = Color(0xFFE8EEF7);

  // text
  static const textPrimary = Color(0xFF1A2332);
  static const textMuted = Color(0xFF5A6B7D);
  static const textDim = Color(0xFF8A97A8);
  static const textFaint = Color(0xFFB0B8C4);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // structure (Tree & Hierarchy)
  static const treeLine = Color(0xFF55D7C4);    // رنگ خط‌چین‌های عمودی
  static const treeDot = Color(0xFF00BFA5);     // رنگ نقاط سبز سلسله‌مراتبی
  static const border = Color(0xFFD7DEE8);
  static const borderSoft = Color(0xFFE6ECF3);
  static const borderHair = Color(0xFFF0F3F7);

  // status
  static const statusOk = Color(0xFF00BFA5);
  static const statusOkBg = Color(0x1A00BFA5);
  static const statusBad = Color(0xFFE53935);
  static const statusBadBg = Color(0x1AE53935);

  // shadows
  static const shadow = Color(0x1A0D47A1);

  // --- Legacy Aliases ---
  static const gold = accent;
  static const goldDim = accentSoft;
  static const goldGlow = Color(0x3300BFA5);
  static const ink = primary;
  static const inkSoft = textPrimary;
  static const paper = bgBase;
  static const card = panel;
  static const brass = accent;
  static const slate = textMuted;
  static const line = border;
}

/// نقش فونت‌ها در ماژول استفساریه.
/// نام خانواده‌ها باید در pubspec.yaml دقیقاً با همین family ثبت شده باشند.
class EstefsariehTypography {
  static const String brand = 'Dima.Sogand.New';
  static const String heading = 'IRANSansWeb';
  static const String body = 'IRANSansWeb';
  static const String medium = 'Vazirmatn-Medium';
}

class EstefsariehDecor {
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: EstefsariehColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static BorderRadius cardRadius = BorderRadius.circular(14);

  // Helper برای گرادیان هدر جدید
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.topLeft,
    colors: [
      Color(0xFF0B8F98),
      Color(0xFF087EA6),
      Color(0xFF0D55A0),
      Color(0xFF062F70),
    ],
    stops: [0.0, 0.30, 0.72, 1.0],
  );

  // Decoration برای خط‌چین عمودی (درختی)
  static const BoxDecoration treeLineDecoration = BoxDecoration(
    border: Border(
      right: BorderSide(
        color: EstefsariehColors.treeLine,
        width: 1.5,
        style: BorderStyle.solid,
      ),
    ),
  );
}
