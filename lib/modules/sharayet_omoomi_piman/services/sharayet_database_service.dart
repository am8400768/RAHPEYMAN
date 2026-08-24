// lib/modules/sharayet_omoomi_piman/services/sharayet_database_service.dart

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sharayet_models.dart';

class SharayetDatabaseService {
  static final SharayetDatabaseService _instance =
      SharayetDatabaseService._internal();

  factory SharayetDatabaseService() => _instance;

  SharayetDatabaseService._internal();

  static Database? _database;

  /// دسترسی به دیتابیس
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// متد عمومی برای سازگاری با Screenها
  Future<void> initDatabase() async {
    await database;
  }

  /// ایجاد و آماده‌سازی دیتابیس
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'sharayet_omoomi_piman.db',
    );

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        final sqlContent = await rootBundle.loadString(
          'assets/data/sharayet_omoomi_piman.sql',
        );

        await _executeSqlScript(db, sqlContent);
      },
    );
  }

  /// اجرای فایل SQL
  Future<void> _executeSqlScript(
    Database db,
    String sqlContent,
  ) async {
    var script = sqlContent;

    // حذف کامنت‌های تک‌خطی
    script = script.replaceAll(
      RegExp(r'--.*'),
      '',
    );

    // حذف PRAGMAهایی که ممکن است با sqflite
    // در زمان ساخت دیتابیس تداخل داشته باشند.
    script = script.replaceAll(
      RegExp(
        r'PRAGMA\s+foreign_keys\s*=\s*ON\s*;',
        caseSensitive: false,
      ),
      '',
    );

    // حذف BEGIN / COMMIT
    script = script.replaceAll(
      RegExp(
        r'BEGIN\s+TRANSACTION\s*;',
        caseSensitive: false,
      ),
      '',
    );

    script = script.replaceAll(
      RegExp(
        r'COMMIT\s*;',
        caseSensitive: false,
      ),
      '',
    );

    final statements = script
        .split(';')
        .map((statement) => statement.trim())
        .where((statement) => statement.isNotEmpty)
        .toList();

    await db.transaction((txn) async {
      for (final statement in statements) {
        await txn.execute(statement);
      }
    });
  }

  // ============================================================
  // Chapters
  // ============================================================

  /// دریافت تمام فصل‌ها
  Future<List<Chapter>> getChapters() async {
    final db = await database;

    final maps = await db.query(
      'chapters',
      orderBy: 'id ASC',
    );

    return maps
        .map((map) => Chapter.fromMap(map))
        .toList();
  }

  /// نام قدیمی متد برای سازگاری
  Future<List<Chapter>> getAllChapters() async {
    return getChapters();
  }

  // ============================================================
  // Articles
  // ============================================================

  /// دریافت تمام مواد یک فصل
  Future<List<Article>> getArticlesByChapter(
    int chapterId,
  ) async {
    final db = await database;

    final maps = await db.query(
      'articles',
      where: 'chapter_id = ?',
      whereArgs: [chapterId],
      orderBy: 'article_number ASC',
    );

    return maps
        .map((map) => Article.fromMap(map))
        .toList();
  }

  /// دریافت یک ماده با شماره ماده
  Future<Article?> getArticleByNumber(
    int articleNumber,
  ) async {
    final db = await database;

    final maps = await db.query(
      'articles',
      where: 'article_number = ?',
      whereArgs: [articleNumber],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Article.fromMap(maps.first);
  }

  /// دریافت تمام مواد
  Future<List<Article>> getAllArticles() async {
    final db = await database;

    final maps = await db.query(
      'articles',
      orderBy: 'article_number ASC',
    );

    return maps
        .map((map) => Article.fromMap(map))
        .toList();
  }

  // ============================================================
  // Related Articles
  // ============================================================

  /// دریافت مواد مرتبط با یک ماده
  Future<List<Article>> getRelatedArticles(
    int articleId,
  ) async {
    final db = await database;

    final relationMaps = await db.query(
      'article_relations',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );

    if (relationMaps.isEmpty) {
      return [];
    }

    final relatedIds = relationMaps
        .map(
          (map) => map['related_article_id'] as int,
        )
        .toList();

    final placeholders = List.filled(
      relatedIds.length,
      '?',
    ).join(',');

    final articleMaps = await db.query(
      'articles',
      where: 'id IN ($placeholders)',
      whereArgs: relatedIds,
      orderBy: 'article_number ASC',
    );

    return articleMaps
        .map((map) => Article.fromMap(map))
        .toList();
  }

  // ============================================================
  // Search
  // ============================================================

  /// جستجو در شماره، عنوان، متن و تفسیر مواد
  Future<List<Article>> searchArticles(
    String query,
  ) async {
    final db = await database;

    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final maps = await db.query(
      'articles',
      where: '''
        CAST(article_number AS TEXT) LIKE ?
        OR title LIKE ?
        OR text LIKE ?
        OR interpretation LIKE ?
      ''',
      whereArgs: [
        '%$normalizedQuery%',
        '%$normalizedQuery%',
        '%$normalizedQuery%',
        '%$normalizedQuery%',
      ],
      orderBy: 'article_number ASC',
    );

    return maps
        .map((map) => Article.fromMap(map))
        .toList();
  }

  // ============================================================
  // Close
  // ============================================================

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }

    _database = null;
  }
}