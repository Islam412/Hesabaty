import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CardTemplate {
  final String id;
  final String name;
  final List<Color> bg;
  final Color text;
  final Color sub;
  final Color accent;
  final String pattern;
  final String? customImage;
  const CardTemplate({required this.id, required this.name, required this.bg, required this.text, required this.sub, required this.accent, this.pattern = 'none', this.customImage});
}

class CardPatternPainter extends CustomPainter {
  final String pattern;
  final Color color;
  CardPatternPainter({required this.pattern, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.2;
    final w = size.width, h = size.height;
    if (pattern == 'mandala') {
      final c = Offset(w / 2, h / 2);
      for (double r = 30; r < w * 0.9; r += 34) canvas.drawCircle(c, r, p);
      for (int i = 0; i < 12; i++) {
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(i * math.pi / 6);
        canvas.drawOval(Rect.fromLTWH(-20, -w * 0.45, 40, w * 0.9), p);
        canvas.restore();
      }
    } else if (pattern == 'lattice') {
      for (double x = -h; x < w; x += 42) {
        canvas.drawLine(Offset(x, 0), Offset(x + h, h), p);
        canvas.drawLine(Offset(x + h, 0), Offset(x, h), p);
      }
    } else if (pattern == 'stars') {
      for (double x = 30; x < w; x += 70) {
        for (double y = 30; y < h; y += 70) {
          canvas.save();
          canvas.translate(x, y);
          canvas.drawRect(const Rect.fromLTWH(-14, -14, 28, 28), p);
          canvas.rotate(math.pi / 4);
          canvas.drawRect(const Rect.fromLTWH(-14, -14, 28, 28), p);
          canvas.restore();
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BusinessCardImageService {
  static TextPainter _tp(String text, double size, Color color, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: size, fontWeight: bold ? FontWeight.w700 : FontWeight.normal, height: 1.4)),
      textDirection: TextDirection.rtl,
    );
    tp.layout(maxWidth: 620);
    return tp;
  }

  static Future<String> generate({
    required CardTemplate t,
    required String businessName,
    required String ownerName,
    required String phone,
    String address = '',
    String activity = '',
  }) async {
    const double width = 720;
    const double height = 460;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rrect = RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, width, height), const Radius.circular(28));
    canvas.clipRRect(rrect);

    final bgPaint = Paint()
      ..shader = LinearGradient(colors: t.bg, begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(const Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    if (t.customImage != null && File(t.customImage!).existsSync()) {
      try {
        final bytes = await File(t.customImage!).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final img = frame.image;
        canvas.drawImageRect(img, Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()), const Rect.fromLTWH(0, 0, width, height), Paint());
        canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), Paint()..color = const Color(0x99000000));
      } catch (_) {}
    }

    final painter = CardPatternPainter(pattern: t.pattern, color: t.accent.withOpacity(0.16));
    painter.paint(canvas, const Size(width, height));
    canvas.drawRRect(rrect, Paint()..style = PaintingStyle.stroke..color = t.accent.withOpacity(0.5)..strokeWidth = 3);

    double y = 70;
    var tp = _tp(businessName, 44, t.text, bold: true);
    tp.paint(canvas, Offset((width - tp.width) / 2, y));
    y += tp.height + 12;
    tp = _tp(ownerName, 27, t.sub, bold: true);
    tp.paint(canvas, Offset((width - tp.width) / 2, y));
    y += tp.height + 10;
    if (activity.isNotEmpty) {
      tp = _tp('💼 $activity', 23, t.sub);
      tp.paint(canvas, Offset((width - tp.width) / 2, y));
      y += tp.height + 6;
    }
    y += 16;
    canvas.drawLine(Offset(70, y), Offset(width - 70, y), Paint()..color = t.accent.withOpacity(0.8)..strokeWidth = 2);
    y += 30;
    tp = _tp('📞 $phone', 28, t.text, bold: true);
    tp.paint(canvas, Offset((width - tp.width) / 2, y));
    y += tp.height + 14;
    if (address.isNotEmpty) {
      tp = _tp('📍 $address', 23, t.sub);
      tp.paint(canvas, Offset((width - tp.width) / 2, y));
    }
    final logo = _tp('حساباتي', 24, t.sub, bold: true);
    logo.paint(canvas, Offset(width / 2 - logo.width / 2, height - 52));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/business_card_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
