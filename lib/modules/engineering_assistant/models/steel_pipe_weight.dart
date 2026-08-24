class SteelPipeWeight {
  const SteelPipeWeight({
    required this.id,
    required this.sizeId,
    required this.thicknessMm,
    required this.weightKgPerM,
  });

  final int id;
  final int sizeId;
  final double thicknessMm;
  final double weightKgPerM;

  factory SteelPipeWeight.fromMap(Map<String, dynamic> map) {
    return SteelPipeWeight(
      id: (map['id'] as num).toInt(),
      sizeId: (map['size_id'] as num).toInt(),
      thicknessMm: (map['thickness_mm'] as num).toDouble(),
      weightKgPerM: (map['weight_kg_per_m'] as num).toDouble(),
    );
  }
}
