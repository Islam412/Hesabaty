import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/app_models.dart';

class PdfService {
  static String _fix(String text) {
    // Simple fix for Arabic text in PDF - reverse for RTL
    return text.split('').reversed.join('');
  }

  static Future<pw.Font> _arabicFont() async {
    try {
      final data = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return pw.Font.ttf(data);
    } catch (_) {
      return pw.Font.helvetica();
    }
  }

  static Future<File> generateContactStatement({
    required Contact contact,
    required String businessName,
    required List<DebtTransaction> transactions,
  }) async {
    final font = await _arabicFont();
    final pdf = pw.Document();

    final sorted = List<DebtTransaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double bal = 0;
    final isCustomer = contact.type == 'customer';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) {
          final rows = <List<String>>[];
          rows.add([
            'التاريخ',
            'البيان',
            'مدفوع',
            'مقبوض',
            'الرصيد بعد',
          ]);

          for (final t in sorted) {
            final sign = isCustomer
                ? (t.type == 'given' ? 1.0 : -1.0)
                : (t.type == 'taken' ? 1.0 : -1.0);
            bal += t.amount * sign;

            final given = (isCustomer && t.type == 'given') || (!isCustomer && t.type == 'taken')
                ? t.amount.toStringAsFixed(2)
                : '';
            final taken = (isCustomer && t.type == 'taken') || (!isCustomer && t.type == 'given')
                ? t.amount.toStringAsFixed(2)
                : '';

            rows.add([
              '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
              t.note ?? (isCustomer ? (t.type == 'given' ? 'معاملة مدفوعة' : 'معاملة مقبوضة') : (t.type == 'taken' ? 'معاملة مقبوضة' : 'معاملة مدفوعة')),
              given,
              taken,
              bal.toStringAsFixed(2),
            ]);
          }

          return [
            pw.Center(
              child: pw.Text(
                businessName,
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'كشف حساب: ${contact.name}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (contact.phone != null && contact.phone!.isNotEmpty)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('رقم الهاتف: ${contact.phone}', style: const pw.TextStyle(fontSize: 12)),
              ),
            pw.SizedBox(height: 6),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'تاريخ التقرير: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: ctx,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
              cellAlignment: pw.Alignment.center,
              data: rows,
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('الرصيد الحالي:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '${bal.abs().toStringAsFixed(2)} ج.م',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                'تم إنشاء هذا التقرير بواسطة تطبيق حساباتي',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeName = contact.name.replaceAll(RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'), '_');
    final file = File('${dir.path}/statement_$safeName.pdf');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    return file;
  }
}
