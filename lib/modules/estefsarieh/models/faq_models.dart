/// Base URL of the official source system. Each [FaqItem.sourceUrl] is used
/// as the payload of the QR code printed on the exported PDF, so a reader
/// can scan it and land on the original question on sama.mporg.ir.
const String kFaqSourceBaseUrl =
    'https://sama.mporg.ir/sites/Publish/SitePages/ZabetehaFAQItemView.aspx?SamaFAQ=1&itemId=';

class FaqItem {
  final int id;
  final String question;
  final String answer;
  final String code;
  final String status;
  final String publishDate;
  final String letterDate;
  final String letterNumber;

  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.code,
    required this.status,
    required this.publishDate,
    required this.letterDate,
    required this.letterNumber,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;
    return FaqItem(
      id: id,
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      publishDate: (json['letter_date'] ?? json['publish_date'] ?? '').toString(),
      letterDate: (json['letter_date'] ?? '').toString(),
      letterNumber: (json['letter_no'] ?? json['letter_number'] ?? '').toString(),
    );
  }


  /// Creates an FAQ item from the SQLite `questions` table.
  ///
  /// SQLite naming is intentionally mapped here to the domain model:
  /// - code         -> code
  /// - letter_date  -> publishDate
  /// - letter_no    -> letterNumber
  factory FaqItem.fromMap(Map<String, dynamic> map) {
    final rawId = map['source_id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;

    return FaqItem(
      id: id,
      question: (map['question'] ?? '').toString(),
      answer: (map['answer'] ?? '').toString(),
      code: (map['code'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      publishDate: (map['letter_date'] ?? '').toString(),
      letterDate: (map['letter_date'] ?? '').toString(),
      letterNumber: (map['letter_no'] ?? '').toString(),
    );
  }

  String get sourceUrl => '$kFaqSourceBaseUrl$id';
}

class FaqMaterial {
  final String materialId;
  final String title;
  final List<FaqItem> items;

  const FaqMaterial({
    required this.materialId,
    required this.title,
    required this.items,
  });


  factory FaqMaterial.fromMap({
    required String materialId,
    required String title,
    required List<FaqItem> items,
  }) {
    return FaqMaterial(
      materialId: materialId,
      title: title,
      items: items,
    );
  }

  factory FaqMaterial.fromJson(Map<String, dynamic> json) {
    return FaqMaterial(
      materialId: (json['material_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FaqCategory {
  final String category;
  final List<FaqMaterial> materials;

  const FaqCategory({required this.category, required this.materials});

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(
      category: (json['category'] ?? '').toString(),
      materials: (json['materials'] as List<dynamic>? ?? const [])
          .map((e) => FaqMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get questionCount => materials.fold(0, (sum, m) => sum + m.items.length);
}
