import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class StatementRow {
  final String date;
  final String label;
  final double amount;
  final bool isGiven;
  StatementRow({required this.date, required this.label, required this.amount, required this.isGiven});
}

class ReceiptImageService {
  static TextPainter _tp(String text, double size, Color color, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, height: 1.3)),
      textDirection: TextDirection.rtl,
    );
    tp.layout();
    return tp;
  }

  static void _center(Canvas canvas, String text, double y, double size, Color color, double width, {bool bold = false}) {
    final tp = _tp(text, size, color, bold: bold);
    tp.paint(canvas, Offset((width - tp.width) / 2, y));
  }

  static void _bg(Canvas canvas, double width, double height) {
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, height), const Radius.circular(28));
    canvas.clipRRect(rrect);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = const Color(0xFFF6F8FB));
    final p = Paint()..color = const Color(0xFFE9EFF7)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (double x = -height; x < width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x + height, height), p);
      canvas.drawLine(Offset(x + height, 0), Offset(x, height), p);
    }
    canvas.drawRRect(rrect, Paint()..style = PaintingStyle.stroke..color = const Color(0xFFD7E3F4)..strokeWidth = 3);
  }

  static Future<String> _save(ui.Picture picture, int w, int h) async {
    final img = await picture.toImage(w, h);
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<String> generateReceiptImage({
    required String businessName,
    required String title,
    required double amount,
    required Color amountColor,
  }) async {
    const width = 720.0;
    const height = 700.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _bg(canvas, width, height);
    double y = 70;
    _center(canvas, businessName, y, 34, const Color(0xFF7FA8D9), width, bold: true);
    y += 90;
    _center(canvas, title, y, 42, const Color(0xFF1F3B5C), width, bold: true);
    y += 80;
    _center(canvas, '${amount.toStringAsFixed(2)} ج.م.', y, 58, amountColor, width, bold: true);
    y += 160;
    _center(canvas, 'حساباتي', y, 40, const Color(0xFF2E7CF6), width, bold: true);
    return _save(recorder.endRecording(), width.toInt(), height.toInt());
  }

  static Future<String> generateStatementImage({
    required String businessName,
    String businessPhone = '',
    required String contactName,
    String contactPhone = '',
    required List<StatementRow> rows,
    required double totalGiven,
    required double totalTaken,
    required double balance,
  }) async {
    const double width = 760;
    const double rowH = 78;
    final double height = 720 + rows.length * rowH + (businessPhone.isNotEmpty ? 40 : 0) + (contactPhone.isNotEmpty ? 40 : 0);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _bg(canvas, width, height);

    double y = 56;
    _center(canvas, businessName, y, 34, const Color(0xFF2E7CF6), width, bold: true);
    y += 52;
    if (businessPhone.isNotEmpty) { _center(canvas, businessPhone, y, 24, const Color(0xFF8AA0B8), width); y += 40; }
    y += 20;
    _center(canvas, 'كشف حساب', y, 42, const Color(0xFF1F3B5C), width, bold: true);
    y += 66;
    _center(canvas, contactName, y, 30, const Color(0xFF1F3B5C), width, bold: true);
    y += 48;
    if (contactPhone.isNotEmpty) { _center(canvas, contactPhone, y, 24, const Color(0xFF8AA0B8), width); y += 40; }
    y += 30;

    final tg = _tp('المدفوع: ${totalGiven.toStringAsFixed(2)}', 26, const Color(0xFF16A34A), bold: true);
    final tk = _tp('المقبوض: ${totalTaken.toStringAsFixed(2)}', 26, const Color(0xFFDC2626), bold: true);
    tg.paint(canvas, Offset(width * 0.25 - tg.width / 2, y));
    tk.paint(canvas, Offset(width * 0.75 - tk.width / 2, y));
    y += 50;

    canvas.drawLine(Offset(40, y), Offset(width - 40, y), Paint()..color = const Color(0xFFD7E3F4)..strokeWidth = 2);
    y += 16;

    for (final r in rows) {
      final labelTp = _tp(r.label, 26, const Color(0xFF1F3B5C), bold: true);
      final dateTp = _tp(r.date, 20, const Color(0xFF8AA0B8));
      final amtTp = _tp('${r.amount.toStringAsFixed(2)} ج.م', 26, r.isGiven ? const Color(0xFFDC2626) : const Color(0xFF16A34A), bold: true);
      labelTp.paint(canvas, Offset(width - 40 - labelTp.width, y + 6));
      dateTp.paint(canvas, Offset(width - 40 - dateTp.width, y + 40));
      amtTp.paint(canvas, Offset(40, y + 16));
      y += rowH - 10;
      canvas.drawLine(Offset(40, y), Offset(width - 40, y), Paint()..color = const Color(0xFFEDF2F8)..strokeWidth = 1);
      y += 10;
    }

    y += 30;
    _center(canvas, 'الرصيد الحالي', y, 28, const Color(0xFF1F3B5C), width, bold: true);
    y += 44;
    _center(canvas, '${balance.abs().toStringAsFixed(2)} ج.م', y, 54, balance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626), width, bold: true);
    y += 90;
    _center(canvas, 'حساباتي', y, 34, const Color(0xFF2E7CF6), width, bold: true);

    return _save(recorder.endRecording(), width.toInt(), height.toInt());
  }
}
