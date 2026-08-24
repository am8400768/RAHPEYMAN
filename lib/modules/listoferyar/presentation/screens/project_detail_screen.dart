import 'package:flutter/material.dart';

import '../../domain/models/project.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';
import 'report_screen.dart';
import 'project_tree_screen.dart';

class ListoferyarProjectDetailScreen extends StatelessWidget {
  const ListoferyarProjectDetailScreen({
    super.key,
    required this.project,
  });

  final ListoferyarProject project;

  Future<void> _openProjectTree(
    BuildContext context,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListoferyarProjectTreeScreen(
          project: project,
        ),
      ),
    );
  }

  Future<void> _openReport(BuildContext context) async {
    final projectId = project.id;
    if (projectId == null) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListoferyarReportScreen(projectId: projectId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ListoferyarTheme.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ListoferyarColors.background,
          appBar: AppBar(
            title: const Text('جزئیات پروژه'),
            leading: IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_forward_rounded,
              ),
            ),
          ),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              30,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient: ListoferyarColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    ListoferyarTheme.softShadow,
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'پروژه',
                      style: TextStyle(
                        fontFamily: ListoferyarTypography.body,
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontFamily: ListoferyarTypography.heading,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (project.contractNumber.isNotEmpty)
                          _MetaChip(
                            icon: Icons.numbers_rounded,
                            text: project.contractNumber,
                          ),
                        if (project.contractDate.isNotEmpty)
                          _MetaChip(
                            icon: Icons.event_rounded,
                            text: project.contractDate,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _ContractPanel(
                project: project,
              ),
              const SizedBox(height: 14),
              _ProjectTreeEntryCard(
                onOpen: () => _openProjectTree(context),
              ),
              const SizedBox(height: 12),
              _ProjectReportEntryCard(
                onOpen: () => _openReport(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTreeEntryCard extends StatelessWidget {
  const _ProjectTreeEntryCard({
    required this.onOpen,
  });

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: ListoferyarTheme.surfaceCard(
            radius: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ListoferyarColors.surfaceBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_tree_rounded,
                  color: ListoferyarColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ساختار پروژه',
                      style: ListoferyarTypography.cardTitle,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'بخش‌ها، زیرشاخه‌ها و ورود میلگرد پروژه را مدیریت کنید.',
                      style: ListoferyarTypography.helper,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'باز کردن ساختار پروژه',
                onPressed: onOpen,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                ),
                color: ListoferyarColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectReportEntryCard extends StatelessWidget {
  const _ProjectReportEntryCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: ListoferyarTheme.surfaceCard(radius: 18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ListoferyarColors.surfaceTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.assessment_rounded,
                  color: ListoferyarColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'گزارش پروژه',
                      style: ListoferyarTypography.cardTitle,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'خلاصه بخش‌ها، تعداد، طول و وزن میلگردها را ببینید.',
                      style: ListoferyarTypography.helper,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'باز کردن گزارش',
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
                color: ListoferyarColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContractPanel extends StatelessWidget {
  const _ContractPanel({
    required this.project,
  });

  final ListoferyarProject project;

  @override
  Widget build(BuildContext context) {
    final fields = <String, String>{
      'کارفرما': project.employer,
      'مشاور': project.consultant,
      'پیمانکار': project.contractor,
      'ناظر مقیم': project.residentSupervisor,
    }
        .entries
        .where(
          (item) => item.value.isNotEmpty,
        )
        .toList();

    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ListoferyarTheme.surfaceCard(
        radius: 17,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اطلاعات قرارداد',
            style: ListoferyarTypography.cardTitle,
          ),
          const SizedBox(height: 10),
          ...fields.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                bottom: 7,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 90,
                    child: Text(
                      item.key,
                      style: ListoferyarTypography.helper,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: ListoferyarTypography.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.17,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: ListoferyarTypography.body,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
