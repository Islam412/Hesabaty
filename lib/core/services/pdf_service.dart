import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/app_models.dart';

class PdfService {
  static Future<pw.Font> _font() async {
    try { return pw.Font.ttf(await rootBundle.load('assets/fonts/Almarai-Regular.ttf')); } catch (_) { return pw.Font.helvetica(); }
  }

  static Future<pw.Font> _bold() async {
    try { return pw.Font.ttf(await rootBundle.load('assets/fonts/Almarai-Bold.ttf')); } catch (_) { return pw.Font.helveticaBold(); }
  }

  static String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<File> generateStatementPdf({
    required String businessName,
    String businessPhone = '',
    required Contact contact,
    required List<DebtTransaction> transactions,
  }) async {
    final font = await _font();
    final bold = await _bold();
    final pdf = pw.Document();
    final sorted = List<DebtTransaction>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
    final isCustomer = contact.type == 'customer';

    double given = 0, taken = 0, bal = 0;
    final rows = <List<String>>[];
    int i = 1;
    for (final t in sorted) {
      final isGiven = isCustomer ? t.type == 'given' : t.type == 'taken';
      if (isGiven) { given += t.amount; } else { taken += t.amount; }
      bal += t.amount * (isGiven ? 1 : -1);
      rows.add([
        '$i',
        fmt(t.date),
        t.note ?? (isGiven ? 'مدفوع' : 'مقبوض'),
        isGiven ? t.amount.toStringAsFixed(2) : '-',
        isGiven ? '-' : t.amount.toStringAsFixed(2),
      ]);
      i++;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: bold),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(businessName, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    if (businessPhone.isNotEmpty) pw.Text(businessPhone, style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Text('حساباتي', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('كشف حساب: ${contact.name}  ${contact.phone ?? ''}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text('من ${sorted.isEmpty ? '-' : fmt(sorted.first.date)} إلى ${sorted.isEmpty ? '-' : fmt(sorted.last.date)}', style: pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('عدد المعاملات: ${sorted.length}', style: pw.TextStyle(fontSize: 8)),
                pw.Text('تم إنشاء التقرير في: ${fmt(DateTime.now())}', style: pw.TextStyle(fontSize: 8)),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                pw.Text('المدفوع: ${given.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.green700)),
                pw.SizedBox(width: 12),
                pw.Text('المقبوض: ${taken.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                pw.SizedBox(width: 12),
                pw.Text('الرصيد: ${bal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Center(child: pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: pw.TextStyle(fontSize: 9))),
        ),
        build: (ctx) => [
          pw.Table.fromTextArray(
            headers: ['#', 'التاريخ', 'البيان', 'أعطيت', 'أخذت'],
            cellAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
            headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey),
            cellStyle: pw.TextStyle(fontSize: 8),
            data: rows,
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(color: PdfColors.blue100, borderRadius: pw.BorderRadius.circular(4)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('إجمالي الدفع', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Row(
                  children: [
                    pw.Text(given.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9, color: PdfColors.green700)),
                    pw.SizedBox(width: 16),
                    pw.Text(taken.toStringAsFixed(2), style: pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeName = contact.name.replaceAll(RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'), '_');
    final file = File('${dir.path}/statement_$safeName.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
