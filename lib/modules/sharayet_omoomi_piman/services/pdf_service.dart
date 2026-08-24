import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/sharayet_models.dart';
import 'sharayet_database_service.dart';

class SharayetPdfService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _brandFont;

  /// ============================================================
  /// بارگذاری فونت‌های PDF
  /// ============================================================

  static Future<void> _loadFonts() async {
    if (_regularFont != null &&
        _boldFont != null &&
        _brandFont != null) {
      return;
    }

    // ------------------------------------------------------------
    // فونت معمولی IRANSans
    // ------------------------------------------------------------

    final regularData = await rootBundle.load(
      'assets/fonts/IRANSansWeb.ttf',
    );

    _regularFont = pw.Font.ttf(regularData);

    // ------------------------------------------------------------
    // چون نسخه Bold نداریم، فعلاً همان فونت معمولی
    // ------------------------------------------------------------

    _boldFont = _regularFont;

    // ------------------------------------------------------------
    // فونت برند / شعار رهپیمان
    // ------------------------------------------------------------

    try {
      final brandData = await rootBundle.load(
        'assets/fonts/Dima.Sogand.New.ttf',
      );

      _brandFont = pw.Font.ttf(brandData);
    } catch (_) {
      _brandFont = _regularFont;
    }
  }

  /// ============================================================
  /// ساخت و اشتراک‌گذاری PDF ماده
  /// ============================================================

  static Future<void> shareOrPrint(Article article) async {
    await _loadFonts();

    final databaseService = SharayetDatabaseService();

    // ------------------------------------------------------------
    // دریافت مواد مرتبط
    // ------------------------------------------------------------

    final relatedArticles =
        await databaseService.getRelatedArticles(article.id);

    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#0D47A1');

    // ------------------------------------------------------------
    // ساخت PDF
    // ------------------------------------------------------------

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        // اجازه ایجاد تعداد صفحات زیاد برای مواد طولانی
        maxPages: 100,

        // --------------------------------------------------------
        // حاشیه صفحه
        // --------------------------------------------------------

        margin: const pw.EdgeInsets.fromLTRB(
          45,
          35,
          45,
          40,
        ),

        // --------------------------------------------------------
        // جهت فارسی
        // --------------------------------------------------------

        textDirection: pw.TextDirection.rtl,

        // --------------------------------------------------------
        // فونت اصلی
        // --------------------------------------------------------

        theme: pw.ThemeData.withFont(
          base: _regularFont!,
          bold: _boldFont!,
        ),

        // --------------------------------------------------------
        // Header
        // --------------------------------------------------------

        header: (context) {
          return _buildHeader(primaryColor);
        },

        // --------------------------------------------------------
        // Footer
        // --------------------------------------------------------

        footer: (context) {
          return _buildFooter(context, primaryColor);
        },

        // --------------------------------------------------------
        // محتوای PDF
        // --------------------------------------------------------

        build: (context) {
          final List<pw.Widget> widgets = [];

          // ======================================================
          // عنوان ماده
          // ======================================================

          widgets.add(
            _buildArticleTitle(
              article,
              primaryColor,
            ),
          );

          widgets.add(
            pw.SizedBox(height: 14),
          );

          // ======================================================
          // عنوان متن ماده
          // ======================================================

          widgets.add(
            _buildSectionTitle(
              'متن ماده',
              primaryColor,
            ),
          );

          widgets.add(
            pw.SizedBox(height: 8),
          );

          // ======================================================
          // متن ماده
          //
          // مهم:
          // متن مستقیماً به MultiPage داده می‌شود تا بتواند
          // آزادانه بین صفحات شکسته شود.
          // ======================================================

          widgets.addAll(
            _buildArticleTextWidgets(
              article.text,
            ),
          );

          // ======================================================
          // تفسیر ماده
          // ======================================================

          if (article.hasInterpretation) {
            widgets.add(
              pw.SizedBox(height: 22),
            );

            widgets.add(
              _buildSectionTitle(
                'تفسیر ماده',
                primaryColor,
              ),
            );

            widgets.add(
              pw.SizedBox(height: 8),
            );

            widgets.addAll(
              _buildArticleTextWidgets(
                article.interpretation!,
              ),
            );
          }

          // ======================================================
          // مواد مرتبط
          // ======================================================

          if (relatedArticles.isNotEmpty) {
            widgets.add(
              pw.SizedBox(height: 28),
            );

            widgets.add(
              _buildSectionTitle(
                'مواد مرتبط',
                primaryColor,
              ),
            );

            widgets.add(
              pw.SizedBox(height: 12),
            );

            for (final relatedArticle in relatedArticles) {
              widgets.addAll(
                _buildRelatedArticleWidgets(
                  relatedArticle,
                  primaryColor,
                ),
              );
            }
          }

          return widgets;
        },
      ),
    );

    // ============================================================
    // تولید PDF
    // ============================================================

    final bytes = await pdf.save();

    // ============================================================
    // اشتراک‌گذاری / چاپ
    // ============================================================

    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'rahpeyman-sharayet-article-${article.articleNumber}.pdf',
    );
  }

  // =============================================================
  // Header
  // =============================================================

  static pw.Widget _buildHeader(
    PdfColor primaryColor,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        bottom: 18,
      ),
      child: pw.Column(
        children: [
          pw.Center(
            child: pw.Text(
              'رهپیمان؛ همراه مهندسین از آموزش تا اجرا',
              textAlign: pw.TextAlign.center,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: _brandFont,
                fontSize: 15,
                color: primaryColor,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(
            color: primaryColor,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  // =============================================================
  // Footer
  // =============================================================

  static pw.Widget _buildFooter(
    pw.Context context,
    PdfColor primaryColor,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        top: 10,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'رهپیمان',
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'صفحه ${context.pageNumber} از ${context.pagesCount}',
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 8,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // Article Title
  // =============================================================

  static pw.Widget _buildArticleTitle(
    Article article,
    PdfColor primaryColor,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: primaryColor,
          width: 0.8,
        ),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        'ماده ${article.articleNumber}: ${article.title}',
        textAlign: pw.TextAlign.right,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(
          font: _boldFont,
          fontSize: 15,
          color: primaryColor,
        ),
      ),
    );
  }

  // =============================================================
  // Section Title
  // =============================================================

  static pw.Widget _buildSectionTitle(
    String title,
    PdfColor primaryColor,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: pw.BoxDecoration(
        color: primaryColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.right,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(
          font: _boldFont,
          fontSize: 11,
          color: PdfColors.white,
        ),
      ),
    );
  }

  // =============================================================
  // Article Text
  // =============================================================

  /// متن ماده را به چند ویجت کوچک‌تر تقسیم می‌کند.
  ///
  /// نکته بسیار مهم:
  /// متن اصلی دیگر داخل یک Container بزرگ قرار نمی‌گیرد.
  /// بنابراین MultiPage می‌تواند متن را بین صفحات بشکند.
  static List<pw.Widget> _buildArticleTextWidgets(
    String text,
  ) {
    final cleanedText = text.trim();

    if (cleanedText.isEmpty) {
      return [
        pw.Text(
          'متنی برای نمایش وجود ندارد.',
          textAlign: pw.TextAlign.right,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: _regularFont,
            fontSize: 11,
            color: PdfColors.grey700,
          ),
        ),
      ];
    }

    final paragraphs = _splitTextIntoParagraphs(
      cleanedText,
    );

    final List<pw.Widget> widgets = [];

    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();

      if (paragraph.isEmpty) {
        continue;
      }

      widgets.add(
        pw.Container(
          width: double.infinity,
          margin: const pw.EdgeInsets.only(
            bottom: 7,
          ),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.grey400,
              width: 0.6,
            ),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            paragraph,
            textAlign: pw.TextAlign.justify,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 11,
              lineSpacing: 4,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  // =============================================================
  // Related Article
  // =============================================================

  /// مواد مرتبط را به قطعات قابل شکستن در صفحات تقسیم می‌کند.
  ///
  /// قبلاً کل ماده مرتبط داخل یک Container قرار داشت.
  /// اگر متن خیلی طولانی بود، همان Container می‌توانست باعث
  /// PdfTooBigPageException شود.
  static List<pw.Widget> _buildRelatedArticleWidgets(
    Article article,
    PdfColor primaryColor,
  ) {
    final List<pw.Widget> widgets = [];

    // ------------------------------------------------------------
    // عنوان ماده مرتبط
    // ------------------------------------------------------------

    widgets.add(
      pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(
          bottom: 7,
        ),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: primaryColor,
            width: 0.7,
          ),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Text(
          'ماده ${article.articleNumber}: ${article.title}',
          textAlign: pw.TextAlign.right,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            font: _boldFont,
            fontSize: 11,
            color: primaryColor,
          ),
        ),
      ),
    );

    // ------------------------------------------------------------
    // متن ماده مرتبط
    // ------------------------------------------------------------

    final text = article.text.trim();

    if (text.isNotEmpty) {
      final paragraphs = _splitTextIntoParagraphs(
        text,
      );

      for (final paragraph in paragraphs) {
        final cleanedParagraph = paragraph.trim();

        if (cleanedParagraph.isEmpty) {
          continue;
        }

        // متن بدون Container بزرگ
        // تا قابلیت شکست بین صفحات حفظ شود.
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(
              right: 10,
              left: 10,
              bottom: 7,
            ),
            child: pw.Text(
              cleanedParagraph,
              textAlign: pw.TextAlign.justify,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 10,
                lineSpacing: 3.5,
              ),
            ),
          ),
        );
      }
    }

    // ------------------------------------------------------------
    // فاصله بعد از ماده مرتبط
    // ------------------------------------------------------------

    widgets.add(
      pw.SizedBox(height: 7),
    );

    return widgets;
  }

  // =============================================================
  // Split Text
  // =============================================================

  /// متن را بر اساس خطوط خالی به پاراگراف تقسیم می‌کند.
  ///
  /// اگر متن دیتابیس پاراگراف‌بندی نشده باشد،
  /// همان متن به‌عنوان یک پاراگراف باقی می‌ماند.
  ///
  /// خود pw.Text قابلیت شکستن بین صفحات را دارد.
  static List<String> _splitTextIntoParagraphs(
    String text,
  ) {
    final normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    if (normalized.isEmpty) {
      return [];
    }

    final paragraphs = normalized.split(
      RegExp(r'\n\s*\n+'),
    );

    if (paragraphs.isEmpty) {
      return [normalized];
    }

    return paragraphs;
  }
}
