import 'package:flutter/material.dart';

import '../models/sharayet_models.dart';
import '../services/sharayet_database_service.dart';
import 'sharayet_article_detail_screen.dart';

class SharayetSearchScreen extends StatefulWidget {
  const SharayetSearchScreen({super.key});

  @override
  State<SharayetSearchScreen> createState() => _SharayetSearchScreenState();
}

class _SharayetSearchScreenState extends State<SharayetSearchScreen> {
  final SharayetDatabaseService _dbService = SharayetDatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Article> _searchResults = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _dbService.searchArticles(normalizedQuery);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('خطا در جستجو: $e');

      if (!mounted) return;

      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Vazirmatn',
          ),
          decoration: const InputDecoration(
            hintText: 'جستجو در شرایط عمومی پیمان...',
            hintStyle: TextStyle(
              color: Colors.white70,
              fontFamily: 'Vazirmatn',
            ),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        backgroundColor: const Color(0xFF0D47A1),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BFA5),
              ),
            )
          : _searchResults.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _searchController.text.trim().isEmpty
                          ? 'عبارت مورد نظر را تایپ کنید'
                          : 'نتیجه‌ای یافت نشد!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final article = _searchResults[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(
                          'ماده ${article.articleNumber}: ${article.title}',
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        subtitle: Text(
                          article.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Vazirmatn',
                          ),
                        ),
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
                      ),
                    );
                  },
                ),
    );
  }
}
