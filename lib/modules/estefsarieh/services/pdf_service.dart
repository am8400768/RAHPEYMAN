import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/faq_models.dart';

class LetterheadConfig {
  final String appName;
  final String appTagline;
  final String companyOrOrgName;

  const LetterheadConfig({
    this.appName = 'رهپیمان',
    this.appTagline = 'رهپیمان، همراه مهندسین از آموزش تا اجرا',
    this.companyOrOrgName = 'رهپیمان',
  });
}

class PdfService {
  static pw.Font? _regular;
  static pw.Font? _bold;
  static pw.Font? _brandFont;
  static pw.Font? _iranSans;
  static pw.MemoryImage? _logoImage;

  /// مقدار متای هر ردیف را تمیز می‌کند (خالی یا مقدار نامعتبر JSON → "-")
  static String _metaValue(Object? raw) {
    final value = (raw ?? '').toString().trim();
    if (value.isEmpty) return '-';
    if (value == 'کدپرسش و پاسخ :' || value == 'کدپرسش و پاسخ:') return '-';
    if (value == 'null' || value == '-') return '-';
    return value;
  }

  static Future<void> _ensureAssets() async {
    if (_regular == null || _bold == null || _brandFont == null || _iranSans == null) {
      final regularData = await rootBundle.load('assets/fonts/Vazirmatn-Medium.ttf');
      final boldData = await rootBundle.load('assets/fonts/IRANSansWeb(FaNum)_Bold.ttf');
      final brandData = await rootBundle.load('assets/fonts/Dima.Sogand.New.ttf');
      final iranSansData = await rootBundle.load('assets/fonts/IRANSansWeb.ttf');

      _regular = pw.Font.ttf(regularData);
      _bold = pw.Font.ttf(boldData);
      _brandFont = pw.Font.ttf(brandData);
      _iranSans = pw.Font.ttf(iranSansData);
    }

    if (_logoImage == null) {
      final logoData = await rootBundle.load('assets/images/logo/10.png');
      _logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    }
  }

  static Future<Uint8List> build({
    required FaqCategory category,
    required FaqMaterial material,
    required FaqItem item,
    LetterheadConfig letterhead = const LetterheadConfig(),
  }) async {
    await _ensureAssets();

    final primaryColor = PdfColor.fromHex('#0D47A1');
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: _regular!,
          bold: _bold!,
        ),
        header: (context) => _buildHeader(primaryColor, letterhead),
        footer: (context) => _buildFooter(context, item, primaryColor),
        build: (context) => [
          _buildModernMetaTable(item, primaryColor),
          pw.SizedBox(height: 25),
          _buildContentBox('متن پرسش', item.question, primaryColor),
          pw.SizedBox(height: 20),
          _buildContentBox('پاسخ رسمی', item.answer, primaryColor),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(PdfColor primaryColor, LetterheadConfig config) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // سمت راست: برند و شعار
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      config.companyOrOrgName,
                      style: pw.TextStyle(
                        font: _brandFont,
                        fontSize: 24,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      config.appTagline,
                      style: pw.TextStyle(
                        font: _iranSans,
                        fontSize: 8.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              // وسط: عنوان سامانه
              pw.Expanded(
                flex: 2,
                child: pw.Center(
                  child: pw.Text(
                    'سامانه استفساریه',
                    style: pw.TextStyle(
                      font: _bold,
                      fontSize: 15,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),

              // سمت چپ: لوگو
              pw.Expanded(
                flex: 3,
                child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: 48,
                    height: 48,
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 8,
                      verticalRadius: 8,
                      child: pw.Image(_logoImage!, fit: pw.BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 1.5, color: primaryColor),
        ],
      ),
    );
  }

  // جدول متا: فقط مقادیر از FaqItem هر سوال/پاسخ پر می‌شود (طراحی ثابت)
  static pw.Widget _buildModernMetaTable(FaqItem item, PdfColor primaryColor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
        children: [
          pw.TableRow(
            children: [
              _tableCell('وضعیت', _metaValue(item.status)),
              _tableCell('تاریخ بخشنامه', _metaValue(item.letterDate)),
              _tableCell('شماره بخشنامه', _metaValue(item.letterNumber)),
              _tableCell('تاریخ پرسش و پاسخ', _metaValue(item.publishDate)),
              _tableCell('کد پرسش و پاسخ', _metaValue(item.code)),
              _tableCell('کد', _metaValue(item.id)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableCell(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            label,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: _bold,
              fontSize: 7.5,
              color: PdfColor.fromHex('#0D47A1'),
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value.isEmpty ? '-' : value,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 8.5),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildContentBox(
    String title,
    String content,
    PdfColor primaryColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: const pw.BorderRadius.only(
              topRight: pw.Radius.circular(6),
              topLeft: pw.Radius.circular(6),
            ),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              font: _bold,
              color: PdfColors.white,
              fontSize: 9,
            ),
          ),
        ),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryColor, width: 1),
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(8),
              bottomRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Text(
            content,
            textAlign: pw.TextAlign.justify,
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 3.5),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
    pw.Context context,
    FaqItem item,
    PdfColor primaryColor,
  ) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#F5F5F5'),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'به استناد بند ۴ دستورالعمل شماره ۲۸۱۳۷۴ مورخ ۱۴۰۲/۰۶/۰۴ با عنوان "نحوه انجام مکاتبات امور قراردادی و مالی نظام فنی و اجرایی کشور" پاسخ ارائه شده به منزله پاسخ رسمی سازمان می‌باشد.',
                  textAlign: pw.TextAlign.justify,
                  style: const pw.TextStyle(fontSize: 7, lineSpacing: 2),
                ),
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: item.sourceUrl.isEmpty
                      ? 'https://rahpeyman.ir'
                      : item.sourceUrl,
                  width: 45,
                  height: 45,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'اسکن جهت دسترسی به منبع اصلی\nدر سایت نظام فنی و اجرایی کشور',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Divider(color: primaryColor, thickness: 0.8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'نرم‌افزار مدیریت استفساریه رهپیمان',
              style: const pw.TextStyle(fontSize: 6.5),
            ),
            pw.Text(
              'صفحه ${context.pageNumber} از ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7),
            ),
            pw.SizedBox(),
          ],
        ),
      ],
    );
  }

  static Future<void> shareOrPrint({
    required FaqCategory category,
    required FaqMaterial material,
    required FaqItem item,
    LetterheadConfig letterhead = const LetterheadConfig(),
  }) async {
    final bytes = await build(
      category: category,
      material: material,
      item: item,
      letterhead: letterhead,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'rahpeyman-estefsarieh-${item.id}.pdf',
    );
  }
}
