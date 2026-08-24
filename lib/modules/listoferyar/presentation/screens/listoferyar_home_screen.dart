import 'package:flutter/material.dart';

import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import 'project_list_screen.dart';

/// داشبورد اصلی لیستوفر‌یار.
/// این صفحه عمداً مستقل از لایه‌های دیتابیس ساخته شده تا UI نهایی
/// قبل از اتصال به Project/License/Backup Repository تثبیت شود.
class ListoferyarHomeScreen extends StatelessWidget {
  const ListoferyarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ListoferyarColors.background,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildBrandHeader(context),
                ),
                SliverToBoxAdapter(
                  child: _buildTrialBanner(context),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    title: 'مدیریت پروژه',
                    subtitle: 'همه پروژه‌های لیستوفر‌یار از اینجا مدیریت می‌شوند.',
                    icon: Icons.account_tree_rounded,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildProjectsCard(context),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    title: 'دسترسی سریع',
                    subtitle: 'ابزارهای پرکاربرد در یک نگاه.',
                    icon: Icons.bolt_rounded,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickActions(context),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    title: 'پشتیبانی و تنظیمات',
                    subtitle: 'راهنما، لایسنس و مدیریت داده‌ها.',
                    icon: Icons.tune_rounded,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSupportGrid(context),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 28),
                ),
                SliverToBoxAdapter(
                  child: _buildFooter(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
        decoration: BoxDecoration(
          gradient: ListoferyarColors.brandGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [ListoferyarTheme.softShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.of(context).maybePop(),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'رهپیمان',
                    style: ListoferyarTypography.brandLarge,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'رهپیمان | همراه مهندسین از آموزش تا اجرا',
                    style: ListoferyarTypography.slogan,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.view_list_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'لیستوفر‌یار',
                        style: ListoferyarTypography.sectionTitle.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.format_list_numbered_rounded,
                color: ListoferyarColors.primary,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ListoferyarColors.surfaceTeal,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ListoferyarColors.accent.withValues(alpha: 0.26),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ListoferyarColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: ListoferyarColors.accent,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نسخه آزمایشی',
                    style: ListoferyarTypography.cardTitle,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'شروع دوره آزمایشی ۶۰ روزه — وضعیت لایسنس در همین بخش نمایش داده خواهد شد.',
                    style: ListoferyarTypography.bodyText,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ListoferyarColors.borderSoft,
                ),
              ),
              child: const Text(
                '۶۰ روز',
                style: ListoferyarTypography.numericStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 34,
            decoration: BoxDecoration(
              color: ListoferyarColors.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: ListoferyarColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: ListoferyarTypography.sectionTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ListoferyarTypography.helper,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: ListoferyarTheme.surfaceCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ListoferyarColors.surfaceBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder_copy_rounded,
                    color: ListoferyarColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'پروژه‌های من',
                        style: ListoferyarTypography.cardTitle,
                      ),
                      SizedBox(height: 3),
                      Text(
                        'تعداد پروژه‌ها نامحدود است و از همین بخش مدیریت می‌شوند.',
                        style: ListoferyarTypography.helper,
                      ),
                    ],
                  ),
                ),
                _MiniBadge(
                  label: 'پروژه‌ها',
                  color: ListoferyarColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: ListoferyarColors.surfaceSoft,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: ListoferyarColors.borderSoft,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 42,
                    color: ListoferyarColors.primaryLight,
                  ),
                  SizedBox(height: 9),
                  Text(
                    'هنوز پروژه‌ای ایجاد نشده است',
                    style: ListoferyarTypography.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'اولین پروژه خود را بسازید و ساختار، اطلاعات میلگرد و گزارش‌های آن را یکجا مدیریت کنید.',
                    style: ListoferyarTypography.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ListoferyarProjectListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('ایجاد پروژه جدید'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              icon: Icons.account_tree_rounded,
              title: 'ساختار پروژه',
              subtitle: 'مدیریت درخت',
              onTap: () => _openProjects(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionCard(
              icon: Icons.straighten_rounded,
              title: 'ورود میلگرد',
              subtitle: 'ثبت سریع',
              onTap: () => _openProjects(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionCard(
              icon: Icons.assessment_rounded,
              title: 'گزارش',
              subtitle: 'نمای کلی',
              onTap: () => _openProjects(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: _SupportCard(
              icon: Icons.help_outline_rounded,
              title: 'راهنما',
              subtitle: 'شروع سریع و آموزش',
              accent: ListoferyarColors.primary,
              onTap: () => _showComingSoon(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SupportCard(
              icon: Icons.verified_user_outlined,
              title: 'لایسنس',
              subtitle: 'فعال‌سازی و وضعیت',
              accent: ListoferyarColors.accent,
              onTap: () => _showComingSoon(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SupportCard(
              icon: Icons.import_export_rounded,
              title: 'داده‌ها',
              subtitle: 'Import / Export',
              accent: ListoferyarColors.primaryLight,
              onTap: () => _showComingSoon(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          Container(
            height: 1,
            color: ListoferyarColors.borderSoft,
          ),
          const SizedBox(height: 11),
          const Text(
            'لیستوفر‌یار',
            style: ListoferyarTypography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          const Text(
            'دقت مهندسی، ساختار منظم، کاربری ساده',
            style: ListoferyarTypography.helper,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'این بخش در مرحله بعد فعال می‌شود.',
        ),
      ),
    );
  }

  void _openProjects(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ListoferyarProjectListScreen(),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: ListoferyarTheme.surfaceCard(radius: 17),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ListoferyarColors.surfaceTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: ListoferyarColors.accent,
                  size: 23,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ListoferyarTypography.cardTitle.copyWith(
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ListoferyarTypography.helper.copyWith(
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 13, 10, 12),
          decoration: ListoferyarTheme.surfaceCard(radius: 17),
          child: Column(
            children: [
              Icon(
                icon,
                color: accent,
                size: 25,
              ),
              const SizedBox(height: 7),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ListoferyarTypography.cardTitle.copyWith(
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ListoferyarTypography.helper.copyWith(
                  fontSize: 9.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: ListoferyarTypography.chip.copyWith(
          color: color,
        ),
      ),
    );
  }
}
