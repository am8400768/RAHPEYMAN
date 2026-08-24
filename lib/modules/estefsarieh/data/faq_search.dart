import '../models/faq_models.dart';

enum MatchSource { question, answer, other }

class FaqSearchResult {
  final FaqCategory category;
  final FaqMaterial material;
  final FaqItem item;
  final MatchSource matchSource;

  const FaqSearchResult({
    required this.category,
    required this.material,
    required this.item,
    required this.matchSource,
  });
}

/// Full-text AND search across title, question, answer and code: every
/// typed word must appear somewhere across those fields (not necessarily
/// in the same one), so "بخشنامه 6405" matches a title that says
/// "بخشنامه" while the number only appears in the body text.
class FaqSearch {
  static List<String> _words(String query) => query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  static List<FaqSearchResult> search(List<FaqCategory> data, String query) {
    final words = _words(query);
    if (words.isEmpty) return const [];

    final results = <FaqSearchResult>[];
    for (final cat in data) {
      for (final mat in cat.materials) {
        for (final item in mat.items) {
          final haystack =
              '${mat.title} ${item.question} ${item.answer} ${item.code}'
                  .toLowerCase();
          final allWordsMatch = words.every((w) => haystack.contains(w));
          if (!allWordsMatch) continue;

          final questionHit =
              words.any((w) => item.question.toLowerCase().contains(w));
          final answerHit =
              words.any((w) => item.answer.toLowerCase().contains(w));
          final source = questionHit
              ? MatchSource.question
              : (answerHit ? MatchSource.answer : MatchSource.other);

          results.add(FaqSearchResult(
            category: cat,
            material: mat,
            item: item,
            matchSource: source,
          ));
        }
      }
    }
    return results;
  }

  /// A short window of [text] centered on the first matched word, so a hit
  /// buried inside a long answer still shows useful context in a result
  /// list instead of always showing the start of the question.
  static String snippetAround(String text, String query, {int radius = 70}) {
    final words = _words(query);
    final lower = text.toLowerCase();
    var idx = -1;
    for (final w in words) {
      final i = lower.indexOf(w);
      if (i != -1 && (idx == -1 || i < idx)) idx = i;
    }
    if (idx == -1) {
      return text.length > radius * 2
          ? '${text.substring(0, radius * 2)}…'
          : text;
    }
    final start = (idx - radius).clamp(0, text.length);
    final end = (idx + radius).clamp(0, text.length);
    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';
    return '$prefix${text.substring(start, end)}$suffix';
  }
}
