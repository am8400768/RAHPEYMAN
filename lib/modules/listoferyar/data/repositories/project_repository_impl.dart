import 'package:sqflite/sqflite.dart';
import '../database/listoferyar_database.dart';
import '../../domain/models/project.dart';

class ProjectRepository {
  ProjectRepository({ListoferyarDatabase? database})
      : _database = database ?? ListoferyarDatabase.instance;
  final ListoferyarDatabase _database;

  Future<int> create(ListoferyarProject project) async {
    final db = await _database.database;
    final now = DateTime.now();
    final values = project.copyWith(createdAt: now, updatedAt: now).toMap()..remove('id');
    return db.insert('projects', values, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<List<ListoferyarProject>> getAll() async {
    final rows = await (await _database.database).query(
      'projects', orderBy: 'updated_at DESC, id DESC');
    return rows.map((e) => ListoferyarProject.fromMap(Map<String,Object?>.from(e))).toList();
  }

  Future<ListoferyarProject?> getById(int id) async {
    final rows = await (await _database.database).query(
      'projects', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : ListoferyarProject.fromMap(Map<String,Object?>.from(rows.first));
  }

  Future<int> update(ListoferyarProject project) async {
    final id = project.id;
    if (id == null) throw ArgumentError('Project id is required for update.');
    final values = project.copyWith(updatedAt: DateTime.now()).toMap()
      ..remove('id')..remove('created_at');
    return (await _database.database).update('projects', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async => (await _database.database).delete(
        'projects', where: 'id = ?', whereArgs: [id]);
}
