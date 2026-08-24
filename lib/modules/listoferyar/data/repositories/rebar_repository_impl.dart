import 'package:sqflite/sqflite.dart';

import '../../domain/models/rebar_item.dart';
import '../database/listoferyar_database.dart';

class RebarRepository {
  RebarRepository({
    ListoferyarDatabase? database,
  }) : _database =
            database ?? ListoferyarDatabase.instance;

  final ListoferyarDatabase _database;

  /// دریافت میلگردهای یک زیرشاخه.
  Future<List<ListoferyarRebarItem>> getByNode(
    int nodeId,
  ) async {
    if (nodeId <= 0) {
      return const [];
    }

    final db = await _database.database;

    final rows = await db.query(
      'rebar_items',
      where: 'node_id = ?',
      whereArgs: <Object?>[nodeId],
      orderBy: 'sort_order ASC, id ASC',
    );

    return rows
        .map(
          (row) => ListoferyarRebarItem.fromMap(
            Map<String, Object?>.from(row),
          ),
        )
        .toList(growable: false);
  }

  /// دریافت تمام میلگردهای یک پروژه.
  Future<List<ListoferyarRebarItem>> getByProject(
    int projectId,
  ) async {
    if (projectId <= 0) {
      return const [];
    }

    final db = await _database.database;

    final rows = await db.query(
      'rebar_items',
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
      orderBy: 'sort_order ASC, id ASC',
    );

    return rows
        .map(
          (row) => ListoferyarRebarItem.fromMap(
            Map<String, Object?>.from(row),
          ),
        )
        .toList(growable: false);
  }

  /// ایجاد ردیف جدید میلگرد.
  Future<int> create(
    ListoferyarRebarItem item,
  ) async {
    final db = await _database.database;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(MAX(sort_order), -1) AS max_order
      FROM rebar_items
      WHERE node_id = ?
      ''',
      <Object?>[item.nodeId],
    );

    final maxOrder = _toInt(
      result.isEmpty
          ? null
          : result.first['max_order'],
    );

    final now = DateTime.now();

    final values = item
        .copyWith(
          sortOrder: maxOrder + 1,
          createdAt: now,
          updatedAt: now,
        )
        .toMap()
      ..remove('id');

    return db.insert(
      'rebar_items',
      values,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// ویرایش ردیف میلگرد.
  Future<int> update(
    ListoferyarRebarItem item,
  ) async {
    final id = item.id;

    if (id == null) {
      throw ArgumentError(
        'شناسه میلگرد برای ویرایش الزامی است.',
      );
    }

    final db = await _database.database;

    final values = item
        .copyWith(
          updatedAt: DateTime.now(),
        )
        .toMap()
      ..remove('id')
      ..remove('created_at');

    return db.update(
      'rebar_items',
      values,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  /// حذف یک ردیف میلگرد.
  Future<int> delete(
    int id,
  ) async {
    if (id <= 0) {
      return 0;
    }

    final db = await _database.database;

    return db.delete(
      'rebar_items',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  /// حذف تمام میلگردهای یک زیرشاخه.
  Future<void> deleteByNode(
    int nodeId,
  ) async {
    if (nodeId <= 0) {
      return;
    }

    final db = await _database.database;

    await db.delete(
      'rebar_items',
      where: 'node_id = ?',
      whereArgs: <Object?>[nodeId],
    );
  }

  static int _toInt(
    Object? value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        -1;
  }
}