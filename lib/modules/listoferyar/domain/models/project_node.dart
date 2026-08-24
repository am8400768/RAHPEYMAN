
class ListoferyarProjectNode {
  const ListoferyarProjectNode({
    this.id,
    required this.projectId,
    this.parentId,
    required this.name,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int projectId;
  final int? parentId;
  final String name;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'project_id': projectId,
        'parent_id': parentId,
        'name': name,
        'sort_order': sortOrder,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory ListoferyarProjectNode.fromMap(Map<String, Object?> map) {
    return ListoferyarProjectNode(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      parentId: map['parent_id'] as int?,
      name: (map['name'] as String?) ?? '',
      sortOrder: (map['sort_order'] as int?) ?? 0,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
