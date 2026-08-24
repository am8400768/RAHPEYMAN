
import 'package:sqflite/sqflite.dart';

import '../database/listoferyar_database.dart';
import '../../domain/models/project_node.dart';

class LayerRepository {
  LayerRepository({ListoferyarDatabase? database})
      : _database = database ?? ListoferyarDatabase.instance;

  final ListoferyarDatabase _database;

  Future<List<ListoferyarProjectNode>> getAllByProject(int projectId) async {
    final db = await _database.database;
    final rows = await db.query(
      'project_nodes',
      where: 'project_id = ?',
      whereArgs: <Object?>[projectId],
      orderBy: 'sort_order ASC, id ASC',
    );

    return rows
        .map(
          (row) => ListoferyarProjectNode.fromMap(
            Map<String, Object?>.from(row),
          ),
        )
        .toList(growable: false);
  }

  Future<int> create({
    required int projectId,
    int? parentId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Node name is required.');
    }

    final db = await _database.database;

    final result = parentId == null
        ? await db.rawQuery(
            """
            SELECT COALESCE(MAX(sort_order), -1) AS max_order
            FROM project_nodes
            WHERE project_id = ? AND parent_id IS NULL
            """,
            <Object?>[projectId],
          )
        : await db.rawQuery(
            """
            SELECT COALESCE(MAX(sort_order), -1) AS max_order
            FROM project_nodes
            WHERE project_id = ? AND parent_id = ?
            """,
            <Object?>[projectId, parentId],
          );

    final maxOrder = (result.first['max_order'] as int?) ?? -1;
    final now = DateTime.now().toIso8601String();

    return db.insert(
      'project_nodes',
      <String, Object?>{
        'project_id': projectId,
        'parent_id': parentId,
        'name': trimmed,
        'sort_order': maxOrder + 1,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> updateName({
    required int id,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Node name is required.');
    }

    final db = await _database.database;

    return db.update(
      'project_nodes',
      <String, Object?>{
        'name': trimmed,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _database.database;
    return db.delete(
      'project_nodes',
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }
}
