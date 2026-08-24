import 'package:flutter/material.dart';

import '../models/sharayet_models.dart';
import '../services/sharayet_database_service.dart';
import '../services/pdf_service.dart';

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
  final SharayetDatabaseService _dbService = SharayetDatabaseService();

  List<Article> _relatedArticles = [];
  bool _isLoadingRelated = true;

  static const String _font = 'Vazirmatn';

  static const Color _primary = Color(0xFF0D47A1);
  static const Color _primaryLight = Color(0xFF1565C0);
  static const Color _accent = Color(0xFF00BFA5);
  static const Color _background = Color(0xFFF5F7FB);
  static const Color _text = Color(0xFF263238);

  @override
  void initState() {
    super.initState();
    _loadRelatedArticles();
  }

  Future<void> _loadRelatedArticles() async {
    try {
      final related =
          await _dbService.getRelatedArticles(widget.article.id);

      if (!mounted) return;

      setState(() {
        _relatedArticles = related;
        _isLoadingRelated = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          title: Text(
            'ماده ${widget.article.articleNumber}',
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'خروجی PDF',
              onPressed: () async {
                try {
                  await SharayetPdfService.shareOrPrint(widget.article);

                  if (!context.mounted) {
                    return;
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'فایل PDF با موفقیت ایجاد شد',
                          style: TextStyle(fontFamily: _font),
                        ),
                        backgroundColor: _accent,
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'خطا در ایجاد PDF: $e',
                          style: const TextStyle(fontFamily: _font),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildArticleHeader(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      title: 'متن ماده',
                      content: widget.article.text,
                      icon: Icons.article_outlined,
                      color: _primary,
                    ),

                    if (widget.article.interpretation != null &&
                        widget.article.interpretation!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'تفسیر',
                        content: widget.article.interpretation!,
                        icon: Icons.lightbulb_outline,
                        color: _accent,
                      ),
                    ],

                    const SizedBox(height: 16),

                    _buildRelatedArticlesCard(),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _primary,
            _primaryLight,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'فصل ${widget.article.chapterNumber}',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: _font,
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'ماده ${widget.article.articleNumber}',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: _font,
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.article.title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: _font,
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border(
            right: BorderSide(
              color: color,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: _font,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(height: 1),

            const SizedBox(height: 14),

            Text(
              content,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: _font,
                fontSize: 15,
                height: 2.0,
                color: _text,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedArticlesCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: const Border(
            right: BorderSide(
              color: Color(0xFFFF6F00),
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.link,
                  color: Color(0xFFFF6F00),
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'مواد مرتبط',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: _font,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF6F00),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Divider(height: 1),

            const SizedBox(height: 12),

            if (_isLoadingRelated)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_relatedArticles.isEmpty)
              const Text(
                'ماده مرتبطی برای این ماده ثبت نشده است.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: _font,
                  fontSize: 14,
                  height: 1.8,
                  color: Color(0xFF757575),
                ),
              )
            else
              Column(
                children: _relatedArticles.map((relatedArticle) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final article =
                          await _dbService.getArticleByNumber(
                        relatedArticle.articleNumber,
                      );

                      if (article != null && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SharayetArticleDetailScreen(
                              article: article,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6F00),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              'ماده ${relatedArticle.articleNumber}',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: _font,
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              relatedArticle.title,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: _font,
                                fontSize: 14,
                                height: 1.6,
                                color: _text,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Icon(
                            Icons.chevron_left,
                            color: Color(0xFFFF6F00),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
