import '../models/faq_models.dart';
import 'faq_database_service.dart';

/// Repository for the Estefsarieh module.
///
/// The UI still consumes the same FaqCategory/FaqMaterial/FaqItem models.
/// Only the data source has moved from JSON to SQLite.
class FaqRepository {
  FaqRepository({
    FaqDatabaseService? databaseService,
  }) : _databaseService = databaseService ?? FaqDatabaseService();

  final FaqDatabaseService _databaseService;
  List<FaqCategory>? _cache;

  Future<List<FaqCategory>> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final categoryRows = await _databaseService.getCategories();
    final categories = <FaqCategory>[];

    for (final categoryRow in categoryRows) {
      final categoryId = (categoryRow['id'] as num).toInt();
      final categoryName = (categoryRow['name'] ?? '').toString();

      final materialRows =
          await _databaseService.getMaterialsByCategory(categoryId);

      final materials = <FaqMaterial>[];

      for (final materialRow in materialRows) {
        final materialDbId = (materialRow['id'] as num).toInt();
        final materialNumber =
            (materialRow['material_number'] ?? '').toString();
        final title = (materialRow['title'] ?? '').toString();

        final questionRows =
            await _databaseService.getQuestionsByMaterial(materialDbId);

        final items = questionRows
            .map(
              FaqItem.fromMap,
            )
            .toList(growable: false);

        materials.add(
          FaqMaterial(
            materialId: materialNumber,
            title: title,
            items: items,
          ),
        );
      }

      categories.add(
        FaqCategory(
          category: categoryName,
          materials: List.unmodifiable(materials),
        ),
      );
    }

    _cache = List.unmodifiable(categories);
    return _cache!;
  }

  Future<void> clearCache() async {
    _cache = null;
  }

  Future<void> dispose() async {
    await _databaseService.close();
  }
}
