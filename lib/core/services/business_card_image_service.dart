import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class BusinessCardImageService {
  static TextPainter _tp(String text, double size, Color color, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, height: 1.4)),
      textDirection: TextDirection.rtl,
    );
    tp.layout(maxWidth: 600);
    return tp;
  }

  static Future<String> generate({
    required String businessName,
    required String ownerName,
    required String phone,
    String address = '',
    String activity = '',
  }) async {
    const double width = 720;
    const double height = 480;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final rrect = RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, width, height), const Radius.circular(28));
    canvas.clipRRect(rrect);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2E7CF6), Color(0xFF1E5BB8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);

    final pat = Paint()..color = const Color(0x22FFFFFF)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (double x = -height; x < width; x += 56) {
      canvas.drawLine(Offset(x, 0), Offset(x + height, height), pat);
    }
    canvas.drawRRect(rrect, Paint()..style = PaintingStyle.stroke..color = const Color(0x55FFFFFF)..strokeWidth = 3);

    double y = 56;
    var tp = _tp(businessName, 42, Colors.white, bold: true);
    tp.paint(canvas, Offset(width - 60 - tp.width, y));
    y += tp.height + 14;
    tp = _tp(ownerName, 28, const Color(0xFFDCE9FF), bold: true);
    tp.paint(canvas, Offset(width - 60 - tp.width, y));
    y += tp.height + 12;
    if (activity.isNotEmpty) {
      tp = _tp('💼 $activity', 24, const Color(0xFFBBD4F7));
      tp.paint(canvas, Offset(width - 60 - tp.width, y));
      y += tp.height + 8;
    }
    canvas.drawLine(Offset(60, y + 10), Offset(width - 60, y + 10), Paint()..color = const Color(0x66FFFFFF)..strokeWidth = 2);
    y += 36;
    tp = _tp('📞 $phone', 28, Colors.white, bold: true);
    tp.paint(canvas, Offset(width - 60 - tp.width, y));
    y += tp.height + 16;
    if (address.isNotEmpty) {
      tp = _tp('📍 $address', 24, const Color(0xFFDCE9FF));
      tp.paint(canvas, Offset(width - 60 - tp.width, y));
    }
    final logo = _tp('حساباتي', 26, const Color(0xFFBBD4F7), bold: true);
    logo.paint(canvas, Offset(60, height - 64));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/business_card_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
