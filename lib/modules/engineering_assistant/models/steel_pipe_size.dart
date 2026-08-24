class SteelPipeSize {
  const SteelPipeSize({
    required this.id,
    required this.nominalMm,
    required this.inchSize,
    required this.odMm,
  });

  final int id;
  final int nominalMm;
  final String inchSize;
  final double odMm;

  factory SteelPipeSize.fromMap(Map<String, dynamic> map) {
    return SteelPipeSize(
      id: (map['id'] as num).toInt(),
      nominalMm: (map['nominal_mm'] as num).toInt(),
      inchSize: map['inch_size']?.toString() ?? '',
      odMm: (map['od_mm'] as num).toDouble(),
    );
  }

  String get displayName => '$inchSize اینچ';

  String get nominalDisplay => '$nominalMm میلی‌متر';
}
