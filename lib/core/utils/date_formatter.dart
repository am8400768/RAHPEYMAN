// core/utils/date_formatter.dart

/// فرمت‌کننده تاریخ با پشتیبانی از فارسی
class DateFormatter {
  DateFormatter._();

  /// تبدیل تاریخ به فرمت فارسی
  static String format(DateTime date) {
    // اینجا می‌توانید از jalali package استفاده کنید
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  /// تبدیل رشته به تاریخ
  static DateTime? parse(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  /// تبدیل تاریخ به فرمت فارسی با حروف
  static String formatPersian(DateTime date) {
    // اینجا می‌توانید از jalali package استفاده کنید
    return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';
  }
}
