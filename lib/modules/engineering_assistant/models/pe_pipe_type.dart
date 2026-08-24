class PePipeType {
  const PePipeType({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory PePipeType.fromMap(Map<String, dynamic> map) {
    return PePipeType(
      id: (map['id'] as num).toInt(),
      name: map['name']?.toString() ?? '',
    );
  }
}
