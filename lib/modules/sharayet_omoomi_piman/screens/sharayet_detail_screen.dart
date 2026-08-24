import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sharayet_models.dart';
import '../services/pdf_service.dart';
import '../services/sharayet_database_service.dart';
import '../theme/sharayet_theme.dart';

class SharayetArticleDetailScreen extends StatefulWidget {
  final Article article;

  const SharayetArticleDetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<SharayetArticleDetailScreen> createState() =>
      _SharayetArticleDetailScreenState();
}

class _SharayetArticleDetailScreenState
    extends State<SharayetArticleDetailScreen> {
  final SharayetDatabaseService _dbService =
      SharayetDatabaseService();

  List<Article> _relatedArticles = [];
  bool _isLoadingRelations = true;

  @override
  void initState() {
    super.initState();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    try {
      final relatedArticles =
          await _dbService.getRelatedArticles(widget.article.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _relatedArticles = relatedArticles;
        _isLoadingRelations = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _relatedArticles = [];
        _isLoadingRelations = false;
      });
    }
  }

  Future<void> _copyArticle() async {
    final interpretation = widget.article.interpretation;

    final buffer = StringBuffer()
      ..writeln(
        'ماده ${widget.article.articleNumber}: ${widget.article.title}',
      )
      ..writeln()
      ..writeln(widget.article.text);

    if (interpretation != null &&
        interpretation.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('تفسیر:')
        ..writeln(interpretation);
    }

    await Clipboard.setData(
      ClipboardData(text: buffer.toString()),
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'متن ماده کپی شد',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: SharayetColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _generatePdf() async {
    try {
      await SharayetPdfService.shareOrPrint(
        widget.article,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'فایل PDF با موفقیت آماده شد',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: SharayetColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'خطا در ایجاد فایل PDF: $error',
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: SharayetColors.statusBad,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SharayetColors.background,
        appBar: AppBar(
          backgroundColor: SharayetColors.primary,
          foregroundColor: SharayetColors.textOnPrimary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            tooltip: 'بازگشت',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'ماده ${widget.article.articleNumber}',
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'کپی متن',
              icon: const Icon(
                Icons.copy_rounded,
                size: 21,
              ),
              onPressed: _copyArticle,
            ),
            IconButton(
              tooltip: 'خروجی PDF',
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 21,
              ),
              onPressed: _generatePdf,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildArticleHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(
                      'متن ماده',
                      Icons.article_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildContentCard(
                      widget.article.text,
                    ),
                    if (widget.article.hasInterpretation) ...[
                      const SizedBox(height: 20),
                      _buildSectionTitle(
                        'تفسیر',
                        Icons.lightbulb_outline_rounded,
                      ),
                      const SizedBox(height: 10),
                      _buildInterpretationCard(
                        widget.article.interpretation!,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                      'مواد مرتبط',
                      Icons.link_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildRelatedArticlesSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SharayetColors.primary,
            SharayetColors.primaryDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: SharayetColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'فصل ${widget.article.chapterNumber}',
              style: const TextStyle(
                fontFamily: 'Vazirmatn',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ماده ${widget.article.articleNumber}',
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.article.title,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: SharayetColors.accentSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: SharayetColors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Vazirmatn',
              color: SharayetColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharayetColors.card,
        borderRadius: SharayetDecor.cardRadius,
        border: Border.all(
          color: SharayetColors.border,
        ),
        boxShadow: SharayetDecor.cardShadow,
      ),
      child: Text(
        content,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          color: SharayetColors.textPrimary,
          fontSize: 15,
          height: 2,
        ),
      ),
    );
  }

  Widget _buildInterpretationCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SharayetColors.statusOkBg,
        borderRadius: SharayetDecor.cardRadius,
        border: Border.all(
          color: SharayetColors.accent.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Text(
        content,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontFamily: 'Vazirmatn',
          color: SharayetColors.textPrimary,
          fontSize: 14.5,
          height: 2,
        ),
      ),
    );
  }

  Widget _buildRelatedArticlesSection() {
    if (_isLoadingRelations) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: SharayetColors.card,
          borderRadius: SharayetDecor.cardRadius,
          border: Border.all(
            color: SharayetColors.border,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: SharayetColors.primary,
          ),
        ),
      );
    }

    if (_relatedArticles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SharayetColors.card,
          borderRadius: SharayetDecor.cardRadius,
          border: Border.all(
            color: SharayetColors.border,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: SharayetColors.textMuted,
              size: 22,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'ماده مرتبطی برای این ماده ثبت نشده است.',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  color: SharayetColors.textMuted,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _relatedArticles
          .map(_buildRelatedArticleCard)
          .toList(),
    );
  }

  Widget _buildRelatedArticleCard(Article article) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: SharayetColors.card,
        borderRadius: SharayetDecor.cardRadius,
        border: Border.all(
          color: SharayetColors.border,
        ),
        boxShadow: SharayetDecor.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: SharayetDecor.cardRadius,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SharayetArticleDetailScreen(
                  article: article,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: SharayetColors.primaryLight.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${article.articleNumber}',
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: SharayetColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ماده ${article.articleNumber}',
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: SharayetColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Vazirmatn',
                          color: SharayetColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_left_rounded,
                  color: SharayetColors.textDim,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}