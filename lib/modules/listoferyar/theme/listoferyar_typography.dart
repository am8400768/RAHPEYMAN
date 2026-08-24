import 'package:flutter/material.dart';

/// تایپوگرافی لیستوفر‌یار؛ همسو با فونت‌های واقعی تعریف‌شده در pubspec.yaml.
abstract final class ListoferyarTypography {
  // Brand
  static const String brand = 'Dima.Sogand.New';

  // Headings / numeric-friendly headings
  static const String heading = 'IRANSansWeb(FaNum)';

  // General text + numbers
  static const String body = 'IRANSansWeb';

  // Secondary / technical UI text
  static const String secondary = 'Vazirmatn';

  static const TextStyle brandLarge = TextStyle(
    fontFamily: brand,
    fontSize: 30,
    height: 1.05,
    color: Colors.white,
  );

  static const TextStyle brandMedium = TextStyle(
    fontFamily: brand,
    fontSize: 24,
    height: 1.05,
    color: Colors.white,
  );

  static const TextStyle slogan = TextStyle(
    fontFamily: body,
    fontSize: 10.5,
    height: 1.5,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle screenTitle = TextStyle(
    fontFamily: heading,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A237E),
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: heading,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A237E),
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: heading,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A237E),
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.8,
    color: Color(0xFF52627A),
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.8,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A237E),
  );

  static const TextStyle numeric = TextStyle(
    fontFamily: body,
    fontSize: 14,
    height: 1.4,
    color: Color(0xFF1A237E),
  );

  static const TextStyle numericStrong = TextStyle(
    fontFamily: body,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1A237E),
  );

  static const TextStyle helper = TextStyle(
    fontFamily: secondary,
    fontSize: 11,
    height: 1.55,
    color: Color(0xFF78879A),
  );

  static const TextStyle chip = TextStyle(
    fontFamily: secondary,
    fontSize: 10.5,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: Color(0xFF52627A),
  );
}
