import 'package:flutter/material.dart';

import '../models/faq_models.dart';
import '../services/pdf_service.dart';
import '../theme/estefsarieh_theme.dart';

class EstefsariehDetailScreen extends StatelessWidget {
  final FaqCategory category;
  final FaqMaterial material;
  final FaqItem item;

  const EstefsariehDetailScreen({
    super.key,
    required this.category,
    required this.material,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: EstefsariehColors.bgBase,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBreadcrumb(),
                      const SizedBox(height: 12),
                      _buildMetaCard(),
                      const SizedBox(height: 18),
                      _buildSectionTitle('متن پرسش'),
                      _buildContentBox(item.question),
                      const SizedBox(height: 18),
                      _buildSectionTitle('پاسخ رسمی'),
                      _buildContentBox(item.answer, isAnswer: true),
                      const SizedBox(height: 18),
                      _buildSourceCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomAction(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: EstefsariehDecor.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x220D47A1),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 15),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // سمت چپ: لوگو + نام انگلیسی برند
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.60),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo/10.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_tree_rounded,
                            color: EstefsariehColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'RAHPEYMAN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ETHNOCEN',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // سمت راست: فلش در بالا، برند و شعار زیر آن
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: Ink(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.38),
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'رهپیمان',
                            style: TextStyle(
                              fontFamily: EstefsariehTypography.brand,
                              fontSize: 23,
                              height: 1,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 7),
                          SizedBox(
                            height: 20,
                            child: VerticalDivider(
                              color: Colors.white70,
                              thickness: 1.1,
                              width: 1.1,
                            ),
                          ),
                          SizedBox(width: 7),
                          Text(
                            'همراه مهندسین از آموزش تا اجرا',
                            style: TextStyle(
                              fontFamily: EstefsariehTypography.heading,
                              fontSize: 9.2,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'جزئیات استفساریه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: EstefsariehTypography.heading,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FD),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFD7EAF5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_tree_rounded,
            color: EstefsariehColors.accent,
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${category.category}  ›  ${material.title.isEmpty ? 'ماده ${material.materialId}' : material.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: EstefsariehTypography.medium,
                fontSize: 10.5,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard() {
    final letterNumber = item.letterNumber.trim().isEmpty
        ? 'ثبت نشده'
        : item.letterNumber.trim();
    final qaCode = item.code.trim().isEmpty ? 'ثبت نشده' : item.code.trim();
    final qaDate = item.publishDate.trim().isEmpty
        ? 'ثبت نشده'
        : item.publishDate.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100D47A1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildMetaCell(
              'شماره بخشنامه',
              letterNumber,
              Icons.description_outlined,
            ),
            _buildMetaDivider(),
            _buildMetaCell(
              'کد پرسش و پاسخ',
              qaCode,
              Icons.qr_code_2_rounded,
            ),
            _buildMetaDivider(),
            _buildMetaCell(
              'تاریخ پرسش و پاسخ',
              qaDate,
              Icons.event_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaCell(String label, String value, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: EstefsariehColors.accent),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: EstefsariehTypography.heading,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: EstefsariehColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: EstefsariehTypography.medium,
                fontSize: 11.2,
                fontWeight: FontWeight.w800,
                color: EstefsariehColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaDivider() {
    return VerticalDivider(
      color: const Color(0xFFD9E4EE),
      width: 1,
      thickness: 1,
      indent: 14,
      endIndent: 14,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: EstefsariehColors.accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: EstefsariehTypography.heading,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: EstefsariehColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBox(
    String text, {
    bool isAnswer = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
      decoration: BoxDecoration(
        color: isAnswer
            ? const Color(0xFFF2FAF8)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAnswer
              ? EstefsariehColors.accent
              : const Color(0xFFDDE6EE),
          width: isAnswer ? 1.2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0D47A1),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontFamily: EstefsariehTypography.body,
          fontSize: 13.2,
          height: 2.0,
          color: EstefsariehColors.textPrimary,
          fontWeight: isAnswer ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSourceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE0E7EE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: EstefsariehColors.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: EstefsariehColors.accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'این محتوا بر اساس اطلاعات ثبت‌شده در بانک استفساریه‌های نظام فنی و اجرایی کشور نمایش داده می‌شود.',
              style: TextStyle(
                fontFamily: EstefsariehTypography.medium,
                fontSize: 10.5,
                height: 1.75,
                color: EstefsariehColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 14,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton.icon(
          onPressed: () => _handlePdfExport(context),
          icon: const Icon(Icons.picture_as_pdf_rounded, size: 23),
          label: const Text(
            'دریافت خروجی PDF رسمی',
            style: TextStyle(
              fontFamily: EstefsariehTypography.heading,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: EstefsariehColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePdfExport(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            color: EstefsariehColors.primary,
          ),
        ),
      );

      await PdfService.shareOrPrint(
        category: category,
        material: material,
        item: item,
        letterhead: const LetterheadConfig(
          companyOrOrgName: 'رهپیمان',
          appTagline: 'رهپیمان، همراه مهندسین از آموزش تا اجرا',
        ),
      );

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطا در تولید فایل: $e',
              style: const TextStyle(
                fontFamily: EstefsariehTypography.body,
              ),
            ),
            backgroundColor: EstefsariehColors.statusBad,
          ),
        );
      }
    }
  }
}
