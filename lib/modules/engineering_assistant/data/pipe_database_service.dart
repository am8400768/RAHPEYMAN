import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/pe_pipe_spec.dart';
import '../models/pe_pipe_type.dart';
import '../models/steel_pipe_size.dart';
import '../models/steel_pipe_weight.dart';

class PipeDatabaseService {
  PipeDatabaseService._();

  static final PipeDatabaseService instance = PipeDatabaseService._();

  static const String _databaseAssetPath = 'assets/data/pipes.db';
  static const String _databaseFileName = 'pipes.db';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(
      databasesPath,
      _databaseFileName,
    );

    final exists = await databaseExists(databasePath);

    if (!exists) {
      final databaseDirectory = Directory(databasesPath);

      if (!await databaseDirectory.exists()) {
        await databaseDirectory.create(recursive: true);
      }

      final byteData = await rootBundle.load(_databaseAssetPath);

      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );

      await File(databasePath).writeAsBytes(
        bytes,
        flush: true,
      );
    }

    return openDatabase(
      databasePath,
      readOnly: true,
    );
  }

  Future<List<SteelPipeSize>> getSteelPipeSizes() async {
    final db = await database;

    final rows = await db.rawQuery(
      '''
      SELECT
        MIN(id) AS id,
        nominal_mm,
        inch_size,
        od_mm
      FROM steel_pipe_sizes
      GROUP BY nominal_mm, inch_size, od_mm
      ORDER BY nominal_mm, id
      ''',
    );

    return rows.map(SteelPipeSize.fromMap).toList(growable: false);
  }

  Future<List<SteelPipeWeight>> getSteelPipeWeights(
    int sizeId,
  ) async {
    final db = await database;

    final rows = await db.query(
      'steel_pipe_weights',
      where: 'size_id = ?',
      whereArgs: [sizeId],
      orderBy: 'thickness_mm ASC',
    );

    return rows.map(SteelPipeWeight.fromMap).toList(growable: false);
  }

  Future<List<PePipeType>> getPePipeTypes() async {
    final db = await database;

    final rows = await db.query(
      'pe_pipe_types',
      orderBy: 'id ASC',
    );

    return rows.map(PePipeType.fromMap).toList(growable: false);
  }

  Future<List<PePipeSpec>> getPePipeSpecs({
    required int typeId,
  }) async {
    final db = await database;

    final rows = await db.query(
      'pe_pipe_specs',
      where: 'type_id = ?',
      whereArgs: [typeId],
      orderBy: 'do_mm ASC, CAST(pn AS REAL) ASC, thickness_mm ASC',
    );

    return rows.map(PePipeSpec.fromMap).toList(growable: false);
  }

  Future<List<double>> getPeDiameters({
    required int typeId,
  }) async {
    final db = await database;

    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT do_mm
      FROM pe_pipe_specs
      WHERE type_id = ?
      ORDER BY do_mm ASC
      ''',
      [typeId],
    );

    return rows
        .map((row) => (row['do_mm'] as num).toDouble())
        .toList(growable: false);
  }

  Future<List<String>> getPePns({
    required int typeId,
    required double doMm,
  }) async {
    final db = await database;

    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT pn
      FROM pe_pipe_specs
      WHERE type_id = ?
        AND do_mm = ?
      ORDER BY CAST(pn AS REAL) ASC
      ''',
      [typeId, doMm],
    );

    return rows
        .map((row) => row['pn']?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<PePipeSpec>> getPeSpecs({
    required int typeId,
    required double doMm,
  }) async {
    final db = await database;

    final rows = await db.query(
      'pe_pipe_specs',
      where: 'type_id = ? AND do_mm = ?',
      whereArgs: [typeId, doMm],
      orderBy: 'CAST(pn AS REAL) ASC, thickness_mm ASC',
    );

    return rows.map(PePipeSpec.fromMap).toList(growable: false);
  }

  Future<PePipeSpec?> findPeSpec({
    required int typeId,
    required double doMm,
    required String pn,
  }) async {
    final db = await database;

    final rows = await db.query(
      'pe_pipe_specs',
      where: 'type_id = ? AND do_mm = ? AND pn = ?',
      whereArgs: [
        typeId,
        doMm,
        pn,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return PePipeSpec.fromMap(rows.first);
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
