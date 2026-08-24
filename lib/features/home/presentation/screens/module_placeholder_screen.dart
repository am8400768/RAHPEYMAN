import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({
    super.key,
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String moduleId;
  final String title;
  final String subtitle;
  final IconData icon;

  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color pageBg = Color(0xFFF3F6FB);
  static const String fontUi = 'Vazirmatn';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;
    final contentMaxWidth = width >= 600 ? 480.0 : double.infinity;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: primaryBlue,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: pageBg,
          bottomNavigationBar: Container(
            color: primaryBlue,
            height: bottomInset > 0 ? bottomInset : 10,
          ),
          appBar: AppBar(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: fontUi,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: primaryBlue, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: fontUi,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: fontUi,
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentTeal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentTeal.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'ماژول «$title» آماده اتصال است.\n'
                          'شناسه فنی: $moduleId\n'
                          'محتوای کامل در فاز بعدی پیاده‌سازی می‌شود.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: fontUi,
                            fontSize: 15.5,
                            height: 1.56,
                            color: Color(0xFF455A64),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'بازگشت به خانه',
                            style: TextStyle(
                              fontFamily: fontUi,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
