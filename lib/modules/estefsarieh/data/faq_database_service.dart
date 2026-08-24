import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite access for the Estefsarieh dataset.
///
/// The bundled database is copied once from Flutter assets to the writable
/// application database directory, then opened read-only for normal queries.
class FaqDatabaseService {
  FaqDatabaseService({
    this.assetPath = 'assets/data/estefsarieh_data.sqlite',
    this.databaseFileName = 'estefsarieh_data.sqlite',
  });

  final String assetPath;
  final String databaseFileName;

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null && existing.isOpen) return existing;

    final dbPath = p.join(await getDatabasesPath(), databaseFileName);
    final file = File(dbPath);

    if (!await file.exists()) {
      await _copyAssetDatabase(file);
    }

    _database = await openDatabase(
      dbPath,
      readOnly: true,
    );

    return _database!;
  }

  Future<void> _copyAssetDatabase(File destination) async {
    await destination.parent.create(recursive: true);
    final bytes = await rootBundle.load(assetPath);
    await destination.writeAsBytes(
      bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      ),
      flush: true,
    );
  }

  Future<List<Map<String, Object?>>> getCategories() async {
    final db = await database;
    return db.query(
      'categories',
      columns: const ['id', 'name'],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, Object?>>> getMaterialsByCategory(
    int categoryId,
  ) async {
    final db = await database;
    return db.query(
      'materials',
      columns: const ['id', 'material_number', 'title', 'category_id'],
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, Object?>>> getQuestionsByMaterial(
    int materialId,
  ) async {
    final db = await database;
    return db.query(
      'questions',
      columns: const [
        'row_id',
        'source_id',
        'material_id',
        'question',
        'answer',
        'code',
        'status',
        'pub',
        'letter_date',
        'letter_no',
      ],
      where: 'material_id = ?',
      whereArgs: [materialId],
      orderBy: 'row_id ASC',
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
