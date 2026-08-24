// modules/sharayet_omoomi_piman/services/sharayet_pdf_service.dart
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/sharayet_models.dart';
import 'sharayet_database_service.dart';

/// سرویس PDF شرایط عمومی پیمان
class SharayetPdfService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static pw.Font? _brandFont;

  static Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null && _brandFont != null) {
      return;
    }

    final regularData = await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf');
    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);

    try {
      final brandData = await rootBundle.load('assets/fonts/Dima.Sogand.ttf');
      _brandFont = pw.Font.ttf(brandData);
    } catch (_) {
      _brandFont = _boldFont;
    }
  }

  static Future<void> shareOrPrint(Article article) async {
    await _loadFonts();

    final databaseService = SharayetDatabaseService();
    final relatedArticles = await databaseService.getRelatedArticles(article.id);

    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('#0D47A1');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(45, 35, 45, 40),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: _regularFont!,
          bold: _boldFont!,
        ),
        header: (context) => _buildHeader(primaryColor),
        build: (context) => [
          _buildArticleTitle(article, primaryColor),
          pw.SizedBox(height: 14),
          _buildSectionTitle('متن ماده', primaryColor),
          pw.SizedBox(height: 8),
          _buildArticleText(article.text),
          if (article.hasInterpretation) ...[
            pw.SizedBox(height: 22),
            _buildSectionTitle('تفسیر ماده', primaryColor),
            pw.SizedBox(height: 8),
            _buildArticleText(article.interpretation!),
          ],
          if (relatedArticles.isNotEmpty) ...[
            pw.SizedBox(height: 28),
            _buildSectionTitle('مواد مرتبط', primaryColor),
            pw.SizedBox(height: 12),
            ...relatedArticles.map(
              (relatedArticle) => _buildRelatedArticle(relatedArticle, primaryColor),
            ),
          ],
        ],
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'rahpeyman-sharayet-article-${article.articleNumber}.pdf',
    );
  }

  static pw.Widget _buildHeader(PdfColor primaryColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
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
          pw.Divider(color: primaryColor, thickness: 1),
        ],
      ),
    );
  }

  static pw.Widget _buildArticleTitle(Article article, PdfColor primaryColor) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor, width: 0.8),
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

  static pw.Widget _buildSectionTitle(String title, PdfColor primaryColor) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  static pw.Widget _buildArticleText(String text) {
    final cleanedText = text.trim();
    if (cleanedText.isEmpty) {
      return pw.Text(
        'متنی برای نمایش وجود ندارد.',
        textAlign: pw.TextAlign.right,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(
          font: _regularFont,
          fontSize: 11,
          color: PdfColors.grey700,
        ),
      );
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        cleanedText,
        textAlign: pw.TextAlign.justify,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(
          font: _regularFont,
          fontSize: 11,
          lineSpacing: 4,
        ),
      ),
    );
  }

  static pw.Widget _buildRelatedArticle(Article article, PdfColor primaryColor) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(11),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.6),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ماده ${article.articleNumber}: ${article.title}',
            textAlign: pw.TextAlign.right,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 11,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 7),
          pw.Text(
            article.text.trim(),
            textAlign: pw.TextAlign.justify,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              lineSpacing: 3.5,
            ),
          ),
        ],
      ),
    );
  }
}