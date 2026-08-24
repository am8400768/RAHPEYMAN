class PePipeSpec {
  const PePipeSpec({
    required this.id,
    required this.typeId,
    required this.pn,
    required this.doMm,
    required this.diMm,
    required this.thicknessMm,
    required this.weightKgPerM,
  });

  final int id;
  final int typeId;
  final String pn;
  final double doMm;
  final double diMm;
  final double thicknessMm;
  final double weightKgPerM;

  factory PePipeSpec.fromMap(Map<String, dynamic> map) {
    return PePipeSpec(
      id: (map['id'] as num).toInt(),
      typeId: (map['type_id'] as num).toInt(),
      pn: map['pn']?.toString() ?? '',
      doMm: (map['do_mm'] as num).toDouble(),
      diMm: (map['di_mm'] as num).toDouble(),
      thicknessMm: (map['thickness_mm'] as num).toDouble(),
      weightKgPerM: (map['weight_kg_per_m'] as num).toDouble(),
    );
  }

  String get pnDisplay => 'PN $pn';
}
