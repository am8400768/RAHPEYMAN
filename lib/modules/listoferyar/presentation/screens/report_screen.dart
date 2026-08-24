import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../import_export/project_export_service.dart';
import '../../reports/project_report_service.dart';
import '../../theme/listoferyar_colors.dart';
import '../../theme/listoferyar_theme.dart';
import '../../theme/listoferyar_typography.dart';

class ListoferyarReportScreen extends StatefulWidget {
  const ListoferyarReportScreen({
    super.key,
    required this.projectId,
  });

  final int projectId;

  @override
  State<ListoferyarReportScreen> createState() =>
      _ListoferyarReportScreenState();
}

class _ListoferyarReportScreenState extends State<ListoferyarReportScreen> {
  final ProjectReportService _reportService = ProjectReportService();
  final ProjectExportService _exportService = ProjectExportService();

  late Future<ListoferyarProjectReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _reportService.build(widget.projectId);
  }

  void _reload() {
    setState(() {
      _reportFuture = _reportService.build(widget.projectId);
    });
  }

  Future<void> _copyExport() async {
    try {
      final content = await _exportService.exportProject(widget.projectId);
      await Clipboard.setData(ClipboardData(text: content));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خروجی پروژه در کلیپ‌بورد کپی شد.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تهیه خروجی انجام نشد: $error')),
      );
    }
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
            title: const Text('گزارش پروژه'),
            leading: IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            actions: [
              IconButton(
                tooltip: 'کپی خروجی',
                onPressed: _copyExport,
                icon: const Icon(Icons.copy_all_rounded),
              ),
              IconButton(
                tooltip: 'بازخوانی',
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: FutureBuilder<ListoferyarProjectReport>(
            future: _reportFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ReportError(
                  message: snapshot.error.toString(),
                  onRetry: _reload,
                );
              }

              final report = snapshot.data;
              if (report == null) {
                return _ReportError(
                  message: 'گزارش پروژه در دسترس نیست.',
                  onRetry: _reload,
                );
              }

              return _ReportContent(report: report);
            },
          ),
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({required this.report});

  final ListoferyarProjectReport report;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: ListoferyarColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [ListoferyarTheme.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'خلاصه پروژه',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                report.project.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (report.project.contractNumber.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'قرارداد: ${report.project.contractNumber}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricCard(
              icon: Icons.account_tree_rounded,
              title: 'بخش‌ها',
              value: '${report.nodes.length}',
            ),
            _MetricCard(
              icon: Icons.format_list_numbered_rounded,
              title: 'ردیف میلگرد',
              value: '${report.rebarItems.length}',
            ),
            _MetricCard(
              icon: Icons.numbers_rounded,
              title: 'تعداد کل',
              value: '${report.totalQuantity}',
            ),
            _MetricCard(
              icon: Icons.straighten_rounded,
              title: 'طول کل',
              value: '${_formatNumber(report.totalLength)} m',
            ),
            _MetricCard(
              icon: Icons.scale_rounded,
              title: 'وزن کل',
              value: '${_formatNumber(report.totalWeight)} kg',
            ),
          ],
        ),
        const SizedBox(height: 18),
        _ReportSection(
          title: 'خلاصه بر اساس قطر',
          icon: Icons.radio_button_checked_rounded,
          child: report.byDiameter.isEmpty
              ? const _EmptyReportMessage(
                  text: 'هنوز اطلاعات میلگردی برای گزارش ثبت نشده است.',
                )
              : Column(
                  children: report.byDiameter
                      .map(
                        (item) => _SummaryRow(
                          title: 'قطر ${_formatNumber(item.diameter)}',
                          leading: '${item.quantity} عدد',
                          trailing:
                              '${_formatNumber(item.totalWeight)} kg | ${_formatNumber(item.totalLength)} m',
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        const SizedBox(height: 12),
        _ReportSection(
          title: 'خلاصه بر اساس محل مصرف',
          icon: Icons.place_rounded,
          child: report.byUsage.isEmpty
              ? const _EmptyReportMessage(
                  text: 'محل مصرفی برای ردیف‌های ثبت‌شده وجود ندارد.',
                )
              : Column(
                  children: report.byUsage
                      .map(
                        (item) => _SummaryRow(
                          title: item.usage,
                          leading: '${item.quantity} عدد',
                          trailing:
                              '${_formatNumber(item.totalWeight)} kg | ${_formatNumber(item.totalLength)} m',
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: ListoferyarTheme.surfaceCard(radius: 15),
        child: Row(
          children: [
            Icon(icon, color: ListoferyarColors.primary, size: 23),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: ListoferyarTypography.helper),
                  const SizedBox(height: 3),
                  Text(value, style: ListoferyarTypography.bodyStrong),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ListoferyarTheme.surfaceCard(radius: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: ListoferyarColors.primary, size: 20),
              const SizedBox(width: 7),
              Text(title, style: ListoferyarTypography.cardTitle),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final String title;
  final String leading;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: ListoferyarTypography.bodyStrong),
          ),
          Text(leading, style: ListoferyarTypography.helper),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              trailing,
              textAlign: TextAlign.left,
              style: ListoferyarTypography.helper,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReportMessage extends StatelessWidget {
  const _EmptyReportMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: ListoferyarTypography.helper);
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assessment_outlined, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تلاش دوباره'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatNumber(double value) {
  final text = value.toStringAsFixed(3);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}
