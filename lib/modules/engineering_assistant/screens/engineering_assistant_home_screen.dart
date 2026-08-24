import 'package:flutter/material.dart';

import '../../estefsarieh/theme/estefsarieh_theme.dart';
import 'block_masonry_screen.dart';
import 'brick_calculator_screen.dart';
import 'cement_calculator_screen.dart';
import 'concrete_calculator_screen.dart';
import 'engineering_calculator_screen.dart';
import 'joist_block_calculator_screen.dart';
import 'pipe_calculator_screen.dart';
import 'profile_yar_screen.dart';
import 'stone_masonry_screen.dart';

class EngineeringAssistantHomeScreen extends StatelessWidget {
  const EngineeringAssistantHomeScreen({super.key});

  static const _tools = <_EngineeringTool>[
    _EngineeringTool(
      'لوله‌یار',
      'مشخصات فنی و وزن لوله‌های فولادی و پلی‌اتیلن',
      Icons.swap_vert_rounded,
      true,
    ),
    _EngineeringTool(
      'پروفیل‌یار',
      'محاسبات وزن و مشخصات پروفیل',
      Icons.view_agenda_rounded,
      true,
    ),
    _EngineeringTool(
      'ماشین‌حساب حرفه‌ای',
      'محاسبات مهندسی و توابع ریاضی',
      Icons.calculate_rounded,
      true,
    ),
    _EngineeringTool(
      'آجر یار',
      'محاسبات تعداد آجر و مصالح موردنیاز',
      Icons.grid_view_rounded,
      true,
    ),
    _EngineeringTool(
      'سیمان یار',
      'محاسبات سیمان و مصالح مصرفی',
      Icons.account_tree_rounded,
      true,
    ),
    _EngineeringTool(
      'بنایی سنگی ملاتی',
      'محاسبات سنگ، ملات، سیمان و هزینه',
      Icons.terrain_rounded,
      true,
    ),
    _EngineeringTool(
      'سقف تیرچه بلوک',
      'محاسبات مصالح و مشخصات سقف تیرچه بلوک',
      Icons.roofing_rounded,
      true,
    ),
    _EngineeringTool(
      'بلوک‌چینی',
      'محاسبه تعداد بلوک، ملات و مصالح موردنیاز',
      Icons.view_module_rounded,
      true,
    ),
    _EngineeringTool(
      'بتن درجا',
      'محاسبات حجم بتن و مصالح موردنیاز',
      Icons.foundation_rounded,
      true,
    ),
    _EngineeringTool(
      'ابزارهای آینده',
      'ابزارهای مهندسی جدید در نسخه‌های آینده',
      Icons.construction_rounded,
      false,
    ),
  ];

  void _openTool(
    BuildContext context,
    _EngineeringTool tool,
  ) {
    switch (tool.title) {
      case 'لوله‌یار':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PipeCalculatorScreen(),
          ),
        );
        return;

      case 'پروفیل‌یار':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProfileYarScreen(),
          ),
        );
        return;

      case 'ماشین‌حساب حرفه‌ای':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EngineeringCalculatorScreen(),
          ),
        );
        return;

      case 'آجر یار':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const BrickCalculatorScreen(),
          ),
        );
        return;

      case 'بنایی سنگی ملاتی':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const StoneMasonryScreen(),
          ),
        );
        return;

      case 'سیمان یار':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CementCalculatorScreen(),
          ),
        );
        return;

      case 'سقف تیرچه بلوک':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const JoistBlockCalculatorScreen(),
          ),
        );
        return;

      case 'بتن درجا':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ConcreteCalculatorScreen(),
          ),
        );
        return;

      case 'بلوک‌چینی':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const BlockMasonryScreen(),
          ),
        );
        return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          '${tool.title} به‌زودی به رهپیمان اضافه می‌شود.',
          style: const TextStyle(
            fontFamily: 'Vazirmatn',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: EstefsariehColors.bgBase,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: EstefsariehColors.primary,
          foregroundColor: Colors.white,
          title: const Text(
            'مهندس‌یار',
            style: TextStyle(
              fontFamily: 'IRANSansWeb(FaNum)',
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            tooltip: 'بازگشت',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_forward_rounded,
            ),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 3 : 2;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        18,
                        16,
                        8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: EstefsariehColors.borderSoft,
                          ),
                          boxShadow: EstefsariehDecor.cardShadow,
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ابزارهای مهندسی',
                              style: TextStyle(
                                fontFamily: 'IRANSansWeb(FaNum)',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: EstefsariehColors.primary,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'ابزار موردنظر خود را انتخاب کنید؛ ابزارهای جدید به‌مرور به مهندس‌یار اضافه می‌شوند.',
                              style: TextStyle(
                                fontFamily: 'Vazirmatn',
                                fontSize: 12.5,
                                height: 1.7,
                                color: EstefsariehColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tool = _tools[index];

                          return _EngineeringToolCard(
                            tool: tool,
                            onTap: () => _openTool(
                              context,
                              tool,
                            ),
                          );
                        },
                        childCount: _tools.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: columns == 3 ? 1.05 : 0.94,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EngineeringToolCard extends StatelessWidget {
  const _EngineeringToolCard({
    required this.tool,
    required this.onTap,
  });

  final _EngineeringTool tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = tool.available;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: available
                  ? EstefsariehColors.accent.withValues(
                      alpha: 0.35,
                    )
                  : EstefsariehColors.borderSoft,
            ),
            boxShadow: EstefsariehDecor.cardShadow,
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: available
                      ? EstefsariehColors.accentSoft
                      : EstefsariehColors.panel2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  tool.icon,
                  color: available
                      ? EstefsariehColors.accent
                      : EstefsariehColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                tool.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'IRANSansWeb(FaNum)',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: EstefsariehColors.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                tool.subtitle,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontSize: 10.5,
                  height: 1.45,
                  color: EstefsariehColors.textMuted,
                ),
              ),
              if (!available) ...[
                const SizedBox(height: 8),
                const Text(
                  'به‌زودی',
                  style: TextStyle(
                    fontFamily: 'Vazirmatn',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: EstefsariehColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EngineeringTool {
  const _EngineeringTool(
    this.title,
    this.subtitle,
    this.icon,
    this.available,
  );

  final String title;
  final String subtitle;
  final IconData icon;
  final bool available;
}
