/// تنظیمات مرکزی برنامه
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.rahpeyman.ir',
  );
  static const String authTokenStorageKey = 'rahpeyman_token';
  static const String googleCloudProjectNumber = String.fromEnvironment(
    'GOOGLE_CLOUD_PROJECT_NUMBER',
  );

  // ============ مهندس‌یار ============

  /// ضریب اتلاف سیمان در بنایی سنگی
  static const double cementWaste = 1.06;

  /// وزن کیسه سیمان
  static const double cementBagKg = 50.0;

  /// مقدار ماسه به ازای هر مترمکعب ملات
  static const double sandTonPerM3 = 1.85;

  /// حجم ملات بندکشی در بلوک‌چینی
  static const double blockMortarPercent = 0.10;

  /// وزن سنگ به ازای هر مترمکعب بنایی سنگی
  static const double stoneTonPerM3 = 2.0;

  // ============ استفساریه ============

  /// URL پایگاه اصلی نظام فنی
  static const String faqSourceBaseUrl =
      'https://sama.mporg.ir/sites/Publish/SitePages/ZabetehaFAQItemView.aspx?SamaFAQ=1&itemId=';

  // ============ لیستوفر‌یار ============

  /// نام دیتابیس لیستوفر‌یار
  static const String listoferyarDatabaseName = 'listoferyar.db';

  /// نسخه دیتابیس لیستوفر‌یار
  static const int listoferyarDatabaseVersion = 1;
}
