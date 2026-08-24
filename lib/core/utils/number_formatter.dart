// core/utils/number_formatter.dart

/// فرمت‌کننده اعداد با پشتیبانی از فارسی و جداکننده هزارگان
class NumberFormatter {
  NumberFormatter._();

  /// تبدیل رشته به عدد با پشتیبانی از اعداد فارسی و عربی
  static double? parse(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    var normalized = value
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll('٫', '.')
        .replaceAll('۰', '0')
        .replaceAll('۱', '1')
        .replaceAll('۲', '2')
        .replaceAll('۳', '3')
        .replaceAll('۴', '4')
        .replaceAll('۵', '5')
        .replaceAll('۶', '6')
        .replaceAll('۷', '7')
        .replaceAll('۸', '8')
        .replaceAll('۹', '9')
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .trim();

    if (normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  /// فرمت عدد با جداکننده هزارگان
  static String format(
    num? value, {
    int decimals = 2,
    bool trimZeros = true,
  }) {
    if (value == null || value.isNaN || value.isInfinite) {
      return '—';
    }

    if (value == 0) {
      return '0';
    }

    final absolute = value.abs();
    if (absolute < 1e-9 || absolute >= 1e15) {
      final scientific = value.toStringAsExponential(6);
      return scientific
          .replaceFirst('e+', ' × 10^')
          .replaceFirst('e-', ' × 10^-')
          .replaceFirst('e', ' × 10^');
    }

    final safeDecimals = decimals.clamp(0, 6);
    var fixed = value.toStringAsFixed(safeDecimals);

    if (trimZeros && fixed.contains('.')) {
      fixed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');
    }

    final parts = fixed.split('.');
    var integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final isNegative = integerPart.startsWith('-');
    if (isNegative) {
      integerPart = integerPart.substring(1);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }

    final formattedInteger = '${isNegative ? '-' : ''}${buffer.toString()}';
    final result = decimalPart.isEmpty
        ? formattedInteger
        : '$formattedInteger.$decimalPart';

    return result;
  }

  /// فرمت قیمت به ریال
  static String formatPrice(num? value) {
    return format(value, decimals: 0);
  }

  /// تبدیل اعداد انگلیسی به فارسی
  static String toPersianDigits(String value) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';

    var result = value;
    for (var i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }

  /// فرمت عدد به فارسی
  static String formatPersian(
    num? value, {
    int decimals = 2,
    bool trimZeros = true,
  }) {
    return toPersianDigits(format(value, decimals: decimals, trimZeros: trimZeros));
  }
}
