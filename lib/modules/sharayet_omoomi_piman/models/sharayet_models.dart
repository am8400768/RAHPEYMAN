// lib/modules/sharayet_omoomi_piman/models/sharayet_models.dart

class Chapter {
  final int id;
  final String title;

  Chapter({
    required this.id,
    required this.title,
  });

  /// شماره فصل
  ///
  /// در دیتابیس فعلی شماره فصل به صورت مستقیم ذخیره نشده
  /// و شناسه فصل به عنوان شماره فصل استفاده می‌شود.
  int get chapterNumber => id;

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'] as int,
      title: map['title'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class Article {
  final int id;
  final int chapterId;
  final int articleNumber;
  final String title;
  final String text;
  final String? interpretation;

  Article({
    required this.id,
    required this.chapterId,
    required this.articleNumber,
    required this.title,
    required this.text,
    this.interpretation,
  });

  /// سازگاری با کدهای قدیمی Screenها
  ///
  /// بعضی Screenها از body استفاده می‌کنند،
  /// اما نام اصلی فیلد در مدل text است.
  String get body => text;

  /// مشخص می‌کند آیا ماده دارای تفسیر است یا خیر.
  bool get hasInterpretation =>
      interpretation != null && interpretation!.trim().isNotEmpty;

  /// شماره فصل مربوط به ماده
  ///
  /// چون اطلاعات فصل داخل Article فقط به صورت chapterId
  /// ذخیره شده است، فعلاً chapterId به عنوان شماره فصل استفاده می‌شود.
  int get chapterNumber => chapterId;

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int,
      chapterId: map['chapter_id'] as int,
      articleNumber: map['article_number'] as int,
      title: map['title'] as String,
      text: map['text'] as String,
      interpretation: map['interpretation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter_id': chapterId,
      'article_number': articleNumber,
      'title': title,
      'text': text,
      'interpretation': interpretation,
    };
  }
}

class ArticleRelation {
  final int articleId;
  final int relatedArticleId;

  ArticleRelation({
    required this.articleId,
    required this.relatedArticleId,
  });

  factory ArticleRelation.fromMap(Map<String, dynamic> map) {
    return ArticleRelation(
      articleId: map['article_id'] as int,
      relatedArticleId: map['related_article_id'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'article_id': articleId,
      'related_article_id': relatedArticleId,
    };
  }
}