import 'package:sqflite/sqflite.dart';

import '../data/database/listoferyar_database.dart';
import 'lisofer_file_format.dart';

class ProjectImportService {
  ProjectImportService({ListoferyarDatabase? database})
      : _database = database ?? ListoferyarDatabase.instance;

  final ListoferyarDatabase _database;

  Future<int> importProject(String source) async {
    final bundle = ListoferyarFileFormat.decodeJson(source);
    final db = await _database.database;

    return db.transaction<int>((txn) async {
      final now = DateTime.now().toIso8601String();
      final projectValues = bundle.project.toMap()
        ..remove('id')
        ..['created_at'] = now
        ..['updated_at'] = now;

      final projectId = await txn.insert(
        'projects',
        projectValues,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      final nodeIdMap = <int, int>{};
      final pendingNodes = [...bundle.nodes];

      while (pendingNodes.isNotEmpty) {
        var inserted = false;

        for (var index = pendingNodes.length - 1; index >= 0; index--) {
          final node = pendingNodes[index];
          final oldId = node.id;
          final parentId = node.parentId;

          if (oldId == null) {
            throw const FormatException('شناسه یکی از بخش‌های پروژه ناقص است.');
          }
          if (parentId != null && !nodeIdMap.containsKey(parentId)) {
            continue;
          }

          final values = node.toMap()
            ..remove('id')
            ..['project_id'] = projectId
            ..['parent_id'] = parentId == null ? null : nodeIdMap[parentId]
            ..['created_at'] = now
            ..['updated_at'] = now;

          final newId = await txn.insert(
            'project_nodes',
            values,
            conflictAlgorithm: ConflictAlgorithm.abort,
          );
          nodeIdMap[oldId] = newId;
          pendingNodes.removeAt(index);
          inserted = true;
        }

        if (!inserted) {
          throw const FormatException(
            'ساختار والد و زیرشاخه‌های فایل معتبر نیست.',
          );
        }
      }

      for (final item in bundle.rebarItems) {
        final oldNodeId = item.nodeId;
        final newNodeId = nodeIdMap[oldNodeId];
        if (newNodeId == null) {
          throw const FormatException(
            'یکی از ردیف‌های میلگرد به بخش ناموجود متصل است.',
          );
        }

        final values = item.toMap()
          ..remove('id')
          ..['project_id'] = projectId
          ..['node_id'] = newNodeId
          ..['created_at'] = now
          ..['updated_at'] = now;

        await txn.insert(
          'rebar_items',
          values,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }

      return projectId;
    });
  }
}
