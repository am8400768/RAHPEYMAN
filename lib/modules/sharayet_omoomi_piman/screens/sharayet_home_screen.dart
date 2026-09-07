import 'package:flutter/material.dart';

import '../models/sharayet_models.dart';
import '../services/sharayet_database_service.dart';
import '../theme/sharayet_theme.dart';
import 'sharayet_chapter_screen.dart';
import 'sharayet_search_screen.dart';

class SharayetHomeScreen extends StatefulWidget {
  const SharayetHomeScreen({super.key});

  @override
  State<SharayetHomeScreen> createState() => _SharayetHomeScreenState();
}

class _SharayetHomeScreenState extends State<SharayetHomeScreen> {
  final SharayetDatabaseService _dbService = SharayetDatabaseService();

  List<Chapter> _chapters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final chapters = await _dbService.getAllChapters();

      if (!mounted) return;

      setState(() {
        _chapters = chapters;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'خطا در بارگذاری فصل‌ها: $e';
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
          title: const Text(
            'شرایط عمومی پیمان',
            style: TextStyle(
              fontFamily: 'Vazirmatn',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SharayetSearchScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: SharayetColors.primary,
                ),
              )
            : _error != null
                ? Center(
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
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Vazirmatn',
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadChapters,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'تلاش مجدد',
                            style: TextStyle(
                              fontFamily: 'Vazirmatn',
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
                  )
                : _chapters.isEmpty
                    ? const Center(
                        child: Text(
                          'هیچ فصلی یافت نشد',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontSize: 16,
                            color: SharayetColors.textMuted,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadChapters,
                        color: SharayetColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            14,
                            16,
                            20,
                          ),
                          itemCount: _chapters.length,
                          itemBuilder: (context, index) {
                            final chapter = _chapters[index];
                            return _buildChapterCard(chapter);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildChapterCard(Chapter chapter) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SharayetChapterScreen(
                  chapter: chapter,
                ),
              ),
            );
          },
          borderRadius: SharayetDecor.cardRadius,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SharayetColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${chapter.id}',
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SharayetColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    chapter.title,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: SharayetColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: SharayetColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}