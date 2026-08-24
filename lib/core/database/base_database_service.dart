// core/database/base_database_service.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

/// سرویس پایه دیتابیس
abstract class BaseDatabaseService {
  Database? _database;

  /// دسترسی به دیتابیس
  Future<Database> get database;

  /// بستن دیتابیس
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }

  /// اجرای فایل SQL
  Future<void> executeSqlScript(
    Database db,
    String sqlContent,
  ) async {
    var script = sqlContent;

    // حذف کامنت‌ها
    script = script.replaceAll(RegExp(r'--.*'), '');

    // حذف PRAGMA‌ها
    script = script.replaceAll(
      RegExp(r'PRAGMA\s+foreign_keys\s*=\s*ON\s*;', caseSensitive: false),
      '',
    );

    // حذف BEGIN / COMMIT
    script = script.replaceAll(
      RegExp(r'BEGIN\s+TRANSACTION\s*;', caseSensitive: false),
      '',
    );
    script = script.replaceAll(
      RegExp(r'COMMIT\s*;', caseSensitive: false),
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

  /// کپی دیتابیس از Assets
  Future<void> copyDatabaseFromAssets({
    required String assetPath,
    required String databaseFileName,
  }) async {
    final file = await getDatabasePath(databaseFileName);
    if (await file.exists()) {
      return;
    }

    await file.parent.create(recursive: true);
    final bytes = await rootBundle.load(assetPath);
    await file.writeAsBytes(
      bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      ),
      flush: true,
    );
  }

  Future<File> getDatabasePath(String fileName) async {
    final dbPath = await getDatabasesPath();
    return File('$dbPath/$fileName');
  }
}
