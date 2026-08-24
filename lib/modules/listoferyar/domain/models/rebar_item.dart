class ListoferyarRebarItem {
  const ListoferyarRebarItem({
    this.id,
    required this.projectId,
    required this.nodeId,
    required this.diameter,
    required this.quantity,
    required this.length,
    required this.spacing,
    this.usage = '',
    this.description = '',
    required this.unitWeight,
    required this.totalLength,
    required this.totalWeight,
    this.sortOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;

  final int projectId;

  final int nodeId;

  /// قطر میلگرد بر حسب میلی‌متر.
  final double diameter;

  /// تعداد میلگرد.
  final int quantity;

  /// طول هر میلگرد بر حسب متر.
  final double length;

  /// فاصله میلگردها بر حسب سانتی‌متر.
  ///
  /// این مقدار صرفاً اطلاعات اجرایی است
  /// و در محاسبه طول و وزن استفاده نمی‌شود.
  final double spacing;

  /// محل مصرف میلگرد.
  final String usage;

  /// توضیحات تکمیلی.
  final String description;

  /// وزن یک متر میلگرد بر حسب کیلوگرم.
  final double unitWeight;

  /// طول کل میلگرد بر حسب متر.
  final double totalLength;

  /// وزن کل میلگرد بر حسب کیلوگرم.
  final double totalWeight;

  /// ترتیب نمایش ردیف.
  final int sortOrder;

  final DateTime? createdAt;

  final DateTime? updatedAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'node_id': nodeId,
      'diameter': diameter,
      'quantity': quantity,
      'length': length,
      'spacing': spacing,
      'usage': usage,
      'description': description,
      'unit_weight': unitWeight,
      'total_length': totalLength,
      'total_weight': totalWeight,
      'sort_order': sortOrder,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ListoferyarRebarItem.fromMap(
    Map<String, Object?> map,
  ) {
    return ListoferyarRebarItem(
      id: _toIntNullable(map['id']),
      projectId: _toInt(map['project_id']),
      nodeId: _toInt(map['node_id']),
      diameter: _toDouble(map['diameter']),
      quantity: _toInt(map['quantity']),
      length: _toDouble(map['length']),
      spacing: _toDouble(map['spacing']),
      usage: map['usage']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      unitWeight: _toDouble(map['unit_weight']),
      totalLength: _toDouble(map['total_length']),
      totalWeight: _toDouble(map['total_weight']),
      sortOrder: _toInt(map['sort_order']),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  ListoferyarRebarItem copyWith({
    int? id,
    int? projectId,
    int? nodeId,
    double? diameter,
    int? quantity,
    double? length,
    double? spacing,
    String? usage,
    String? description,
    double? unitWeight,
    double? totalLength,
    double? totalWeight,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListoferyarRebarItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      nodeId: nodeId ?? this.nodeId,
      diameter: diameter ?? this.diameter,
      quantity: quantity ?? this.quantity,
      length: length ?? this.length,
      spacing: spacing ?? this.spacing,
      usage: usage ?? this.usage,
      description: description ?? this.description,
      unitWeight: unitWeight ?? this.unitWeight,
      totalLength: totalLength ?? this.totalLength,
      totalWeight: totalWeight ?? this.totalWeight,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _toInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static int? _toIntNullable(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static double _toDouble(Object? value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}