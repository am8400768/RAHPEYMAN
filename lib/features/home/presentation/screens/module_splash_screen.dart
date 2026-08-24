import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Splash اختصاصی هر ماژول رهپیمان
/// - معرفی کوتاه
/// - آماده‌سازی اولیه
/// - قابلیت اتصال بعدی به بارگذاری واقعی داده
class ModuleSplashScreen extends StatefulWidget {
  const ModuleSplashScreen({
    super.key,
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.nextPage,
    this.minDisplay = const Duration(milliseconds: 1000),
    this.loader,
  });

  final String moduleId;
  final String title;
  final String subtitle;
  final IconData icon;

  /// صفحه‌ای که بعد از Splash باز می‌شود
  final Widget nextPage;

  /// حداقل زمان نمایش Splash (پیش‌فرض حدود ۱ ثانیه)
  final Duration minDisplay;

  /// بارگذاری واقعی آینده (مثلاً خواندن JSON/DB)
  /// اگر null باشد فقط تأخیر نمایشی اجرا می‌شود
  final Future<void> Function()? loader;

  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const String fontBrandFa = 'Dima.Sogand.New';
  static const String fontUi = 'Vazirmatn';

  @override
  State<ModuleSplashScreen> createState() => _ModuleSplashScreenState();
}

class _ModuleSplashScreenState extends State<ModuleSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  double _progress = 0.0;
  String _statusText = 'در حال آماده‌سازی...';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final sw = Stopwatch()..start();

    // پیشرفت نمایشی نرم
    await _animateProgress(0.15, const Duration(milliseconds: 120));
    if (!mounted) return;
    setState(() => _statusText = 'بارگذاری ماژول ${widget.title}...');

    await _animateProgress(0.45, const Duration(milliseconds: 180));

    // نقطه اتصال آینده برای لود واقعی
    try {
      if (widget.loader != null) {
        if (!mounted) return;
        setState(() => _statusText = 'دریافت اطلاعات...');
        await widget.loader!.call();
      } else {
        // فعلاً فقط آماده‌سازی نمایشی
        await Future<void>.delayed(const Duration(milliseconds: 220));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _statusText = 'آماده‌سازی اولیه انجام شد');
    }

    if (!mounted) return;
    await _animateProgress(0.85, const Duration(milliseconds: 160));
    if (!mounted) return;
    setState(() => _statusText = 'ورود به بخش...');

    // رعایت حداقل زمان نمایش
    final remain = widget.minDisplay - sw.elapsed;
    if (remain > Duration.zero) {
      await Future<void>.delayed(remain);
    }

    if (!mounted) return;
    await _animateProgress(1.0, const Duration(milliseconds: 120));
    if (!mounted) return;

    _goNext();
  }

  Future<void> _animateProgress(double target, Duration duration) async {
    final start = _progress;
    final frames = duration.inMilliseconds <= 0
        ? 1
        : (duration.inMilliseconds / 16).ceil().clamp(1, 40);
    final step = (target - start) / frames;

    for (var i = 0; i < frames; i++) {
      await Future<void>.delayed(
        Duration(milliseconds: (duration.inMilliseconds / frames).round()),
      );
      if (!mounted) return;
      setState(() {
        _progress = (start + step * (i + 1)).clamp(0.0, 1.0);
      });
    }
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: widget.nextPage,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;
    final contentMaxWidth = width >= 600 ? 480.0 : double.infinity;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ModuleSplashScreen.primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: ModuleSplashScreen.primaryBlue,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ModuleSplashScreen.primaryBlue,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16 + bottomInset),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // لوگوی ماژول
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.icon,
                            size: 46,
                            color: ModuleSplashScreen.primaryBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // نام ماژول
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: ModuleSplashScreen.fontBrandFa,
                          fontSize: 28,
                          height: 1.15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ModuleSplashScreen.fontUi,
                          fontSize: 13.5,
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // برند رهپیمان
                      Text(
                        'رهپیمان',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ModuleSplashScreen.fontUi,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.2,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // نوار بارگذاری
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: SizedBox(
                          height: 7,
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              ModuleSplashScreen.accentTeal,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ModuleSplashScreen.fontUi,
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        '${(_progress * 100).round()}٪',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ModuleSplashScreen.fontUi,
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),

                      const Spacer(flex: 1),

                      Text(
                        'همراه مهندسین از آموزش تا اجرا',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: ModuleSplashScreen.fontUi,
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.65),
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
