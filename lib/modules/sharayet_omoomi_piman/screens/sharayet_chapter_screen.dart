// lib/modules/sharayet_omoomi_piman/screens/sharayet_chapter_screen.dart

import 'package:flutter/material.dart';

import '../models/sharayet_models.dart';
import '../services/sharayet_database_service.dart';
import '../theme/sharayet_theme.dart';
import 'sharayet_article_detail_screen.dart';

class SharayetChapterScreen extends StatefulWidget {
  final Chapter chapter;

  const SharayetChapterScreen({
    super.key,
    required this.chapter,
  });

  @override
  State<SharayetChapterScreen> createState() =>
      _SharayetChapterScreenState();
}

class _SharayetChapterScreenState extends State<SharayetChapterScreen> {
  final SharayetDatabaseService _dbService =
      SharayetDatabaseService();

  List<Article> _articles = [];
  bool _isLoading = true;
  String? _error;

  static const String _fontFamily = 'Vazirmatn';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final articles =
          await _dbService.getArticlesByChapter(widget.chapter.id);

      if (!mounted) return;

      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'خطا در بارگذاری مواد: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: SharayetColors.primary,
          foregroundColor: SharayetColors.textOnPrimary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.chapter.title,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildChapterHeader(),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: SharayetColors.primary,
                      ),
                    )
                  : _error != null
                      ? _buildErrorState()
                      : _articles.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadArticles,
                              color: SharayetColors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  20,
                                ),
                                itemCount: _articles.length,
                                itemBuilder: (context, index) {
                                  final article = _articles[index];

                                  return _buildArticleCard(article);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16,
                height: 1.7,
                color: Colors.red,
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _loadArticles,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'تلاش مجدد',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: SharayetColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'هیچ ماده‌ای یافت نشد',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: SharayetColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildChapterHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: SharayetColors.card,
        borderRadius: SharayetDecor.cardRadius,
        border: Border.all(
          color: SharayetColors.border,
        ),
        boxShadow: SharayetDecor.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: SharayetColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: SharayetColors.primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'فصل ${widget.chapter.id}',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SharayetColors.textPrimary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${_articles.length} ماده',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 11.5,
                    color: SharayetColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    final hasInterpretation =
        article.interpretation != null &&
        article.interpretation!.trim().isNotEmpty;

    return Container(
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            SharayetColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ماده ${article.articleNumber}',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: SharayetColors.primary,
                          height: 1.5,
                        ),
                      ),
                    ),

                    if (hasInterpretation) ...[
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SharayetColors.accentSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'دارای تفسیر',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: SharayetColors.accent,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  article.title,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: SharayetColors.primary,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  article.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12.2,
                    color: SharayetColors.textPrimary,
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'مشاهده جزئیات',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: SharayetColors.primary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Icon(
                      Icons.arrow_back_ios,
                      size: 12,
                      color: SharayetColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}