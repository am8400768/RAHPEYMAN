import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rahpeyman/modules/estefsarieh/screens/estefsarieh_home_screen.dart';
import 'package:rahpeyman/modules/engineering_assistant/screens/engineering_assistant_splash_screen.dart';
import 'package:rahpeyman/modules/listoferyar/presentation/screens/listoferyar_home_screen.dart';
import 'package:rahpeyman/modules/sharayet_omoomi_piman/screens/sharayet_splash_screen.dart';
import 'package:rahpeyman/features/courses/presentation/screens/courses_screen.dart';

class HomePlaceholderScreen extends StatefulWidget {
  const HomePlaceholderScreen({super.key});

  @override
  State<HomePlaceholderScreen> createState() => _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends State<HomePlaceholderScreen> {
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color pageBg = Color(0xFFF3F6FB);

  static const String fontBrandFa = 'Dima.Sogand.New';
  static const String fontUi = 'Vazirmatn';

  static const List<_HomeModuleItem> modules = [
    _HomeModuleItem(
      id: 'courses',
      title: 'دوره‌های آموزشی',
      subtitle: 'آموزش از پایه تا اجرا',
      icon: Icons.school_rounded,
    ),
    _HomeModuleItem(
      id: 'general_conditions',
      title: 'شرایط عمومی پیمان',
      subtitle: 'مطالعه و تفسیر مواد',
      icon: Icons.gavel_rounded,
    ),
    _HomeModuleItem(
      id: 'inquiries',
      title: 'استفساریه‌ها',
      subtitle: 'سؤال و پاسخ‌های فنی',
      icon: Icons.question_answer_rounded,
    ),
    _HomeModuleItem(
      id: 'listoferyar',
      title: 'لیستوفریار',
      subtitle: 'مدیریت و گزارش میلگرد',
      icon: Icons.view_module_rounded,
    ),
    _HomeModuleItem(
      id: 'engineering_assistant',
      title: 'مهندس‌یار',
      subtitle: 'ماشین‌حساب و ابزارهای مهندسی',
      icon: Icons.engineering_rounded,
    ),
    _HomeModuleItem(
      id: 'announcements',
      title: 'اطلاعیه‌ها',
      subtitle: 'جدیدترین اطلاعیه‌ها',
      icon: Icons.campaign_rounded,
    ),
    _HomeModuleItem(
      id: 'about',
      title: 'درباره ما',
      subtitle: 'معرفی رهپیمان',
      icon: Icons.info_outline_rounded,
    ),
    _HomeModuleItem(
      id: 'favorites',
      title: 'علاقه‌مندی‌ها',
      subtitle: 'موارد ذخیره‌شده شما',
      icon: Icons.favorite_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setSystemBarsBlue();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setSystemBarsBlue();
  }

  void _setSystemBarsBlue() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: primaryBlue,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: primaryBlue,
      ),
    );
  }

  void openModuleWithSplash({
    required BuildContext context,
    required String moduleId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Duration minDisplay,
  }) {
    switch (moduleId) {
      case 'general_conditions':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SharayetSplashScreen(),
          ),
        );
        return;

      case 'inquiries':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EstefsariehHomeScreen(),
          ),
        );
        return;

      case 'engineering_assistant':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EngineeringAssistantSplashScreen(),
          ),
        );
        return;

      case 'listoferyar':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ListoferyarHomeScreen(),
          ),
        );
        return;

      case 'courses':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CoursesScreen(),
          ),
        );
        return;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'بخش "$title" در حال آماده‌سازی است',
              style: const TextStyle(fontFamily: fontUi),
            ),
          ),
        );
    }
  }

  void _openModule(_HomeModuleItem item) {
    openModuleWithSplash(
      context: context,
      moduleId: item.id,
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      minDisplay: const Duration(milliseconds: 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;

    final contentMaxWidth = width >= 600 ? 480.0 : double.infinity;
    final aspect = width < 360 ? 0.92 : 1.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: primaryBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: primaryBlue,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: primaryBlue,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: pageBg,
          bottomNavigationBar: Container(
            width: double.infinity,
            color: primaryBlue,
            height: bottomInset > 0 ? bottomInset : 10,
          ),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: contentMaxWidth,
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                        child: _HomeHeader(
                          onNotificationsTap: () {
                            _openModule(
                              const _HomeModuleItem(
                                id: 'announcements',
                                title: 'اطلاعیه‌ها',
                                subtitle: 'جدیدترین اطلاعیه‌ها',
                                icon: Icons.campaign_rounded,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                        child: _SearchBar(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'موتور جستجو در مرحله بعد فعال می‌شود',
                                  style: TextStyle(fontFamily: fontUi),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 2, 18, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: accentTeal,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'بخش‌های اصلی',
                              style: TextStyle(
                                fontFamily: fontUi,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: aspect,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = modules[index];

                            return _ModuleCard(
                              item: item,
                              onTap: () => _openModule(item),
                            );
                          },
                          childCount: modules.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14, 6, 14, 24),
                        child: _LatestAnnouncementCard(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.onNotificationsTap,
  });

  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _HomePlaceholderScreenState.primaryBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _HomePlaceholderScreenState.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_forward_rounded),
            color: Colors.white,
            iconSize: 24,
            tooltip: 'بازگشت',
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'رهپیمان',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _HomePlaceholderScreenState.fontBrandFa,
                    fontSize: 24,
                    height: 1.1,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'همراه مهندسین از آموزش تا اجرا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _HomePlaceholderScreenState.fontUi,
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationsTap,
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.white,
            iconSize: 24,
            tooltip: 'اطلاعیه‌ها',
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _HomePlaceholderScreenState.primaryBlue.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: _HomePlaceholderScreenState.primaryBlue,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'جستجوی سراسری در رهپیمان...',
              style: TextStyle(
                fontFamily: _HomePlaceholderScreenState.fontUi,
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.item,
    required this.onTap,
  });

  final _HomeModuleItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _HomePlaceholderScreenState.primaryBlue.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: _HomePlaceholderScreenState.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _HomePlaceholderScreenState.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: _HomePlaceholderScreenState.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: _HomePlaceholderScreenState.fontUi,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _HomePlaceholderScreenState.primaryBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _HomePlaceholderScreenState.fontUi,
                fontSize: 11,
                height: 1.25,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestAnnouncementCard extends StatelessWidget {
  const _LatestAnnouncementCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _HomePlaceholderScreenState.accentTeal.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: _HomePlaceholderScreenState.primaryBlue.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _HomePlaceholderScreenState.accentTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: _HomePlaceholderScreenState.accentTeal,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آخرین اطلاعیه',
                  style: TextStyle(
                    fontFamily: _HomePlaceholderScreenState.fontUi,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _HomePlaceholderScreenState.primaryBlue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'صفحه اصلی آماده است. با لمس هر بخش، ابتدا Splash ماژول و سپس صفحه مربوطه باز می‌شود.',
                  style: TextStyle(
                    fontFamily: _HomePlaceholderScreenState.fontUi,
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF616161),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  double _scale = 1.0;

  void _down(TapDownDetails _) {
    setState(() => _scale = 0.96);
  }

  void _up([_]) {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapCancel: _up,
      onTapUp: (_) {
        _up();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class _HomeModuleItem {
  const _HomeModuleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
}
