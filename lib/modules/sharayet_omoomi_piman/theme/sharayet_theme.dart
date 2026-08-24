import 'package:flutter/material.dart';

class SharayetColors {
  // ============================================================
  // رنگ‌های اصلی برند
  // ============================================================

  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);

  static const Color accent = Color(0xFF00BFA5);
  static const Color accentSoft = Color(0x1A00BFA5);

  // ============================================================
  // پس‌زمینه و سطوح
  // ============================================================

  static const Color bgBase = Color(0xFFF5F7FB);

  // نام اصلی
  static const Color background = bgBase;

  static const Color panel = Color(0xFFFFFFFF);
  static const Color panel2 = Color(0xFFF0F4FA);
  static const Color panel3 = Color(0xFFE8EEF7);

  // نام‌های مورد استفاده در ویجت‌ها
  static const Color card = panel;

  // ============================================================
  // رنگ متن
  // ============================================================

  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF5A6B7D);
  static const Color textMuted = Color(0xFF5A6B7D);
  static const Color textDim = Color(0xFF8A97A8);
  static const Color textFaint = Color(0xFFB0B8C4);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================================
  // Border
  // ============================================================

  static const Color border = Color(0xFFD7DEE8);
  static const Color borderSoft = Color(0xFFE6ECF3);
  static const Color borderHair = Color(0xFFF0F3F7);

  // ============================================================
  // وضعیت‌ها
  // ============================================================

  static const Color statusOk = Color(0xFF00BFA5);
  static const Color statusOkBg = Color(0x1A00BFA5);

  static const Color statusBad = Color(0xFFE53935);
  static const Color statusBadBg = Color(0x1AE53935);

  // ============================================================
  // سایه
  // ============================================================

  static const Color shadow = Color(0x1A0D47A1);

  // ============================================================
  // Legacy aliases
  // برای سازگاری با کدهای قدیمی
  // ============================================================

  static const Color gold = accent;
  static const Color goldDim = accentSoft;
  static const Color goldGlow = Color(0x3300BFA5);

  static const Color ink = primary;
  static const Color inkSoft = textPrimary;

  static const Color paper = bgBase;

  static const Color brass = accent;
  static const Color slate = textMuted;
  static const Color line = border;
}

class SharayetDecor {
  // ============================================================
  // شعاع کارت‌ها
  // ============================================================

  static final BorderRadius cardRadius = BorderRadius.circular(14);

  // ============================================================
  // سایه کارت‌ها
  // ============================================================

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: SharayetColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
