import 'dart:math';
import 'package:flutter/material.dart';

class PatternLock extends StatefulWidget {
  final int size;
  final void Function(List<int> points) onCompleted;
  final Color color;
  final Color errorColor;
  const PatternLock({super.key, this.size = 3, required this.onCompleted, this.color = const Color(0xFF2E7CF6), this.errorColor = const Color(0xFFDC2626)});
  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  final List<int> _selected = [];
  bool _dragging = false;
  Offset? _currentPoint;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onPanStart: (d) {
          _dragging = true;
          _selected.clear();
          _error = false;
          _currentPoint = d.localPosition;
          setState(() {});
        },
        onPanUpdate: (d) {
          _currentPoint = d.localPosition;
          setState(() {});
        },
        onPanEnd: (_) {
          _dragging = false;
          _currentPoint = null;
          widget.onCompleted(List<int>.from(_selected));
          setState(() {});
        },
        child: LayoutBuilder(
          builder: (ctx, c) {
            final w = c.maxWidth;
            final gap = w / (widget.size + 1);
            final dots = <Offset>[];
            for (int r = 0; r < widget.size; r++) {
              for (int col = 0; col < widget.size; col++) {
                dots.add(Offset(gap * (col + 1), gap * (r + 1)));
              }
            }
            return CustomPaint(
              painter: _PatternPainter(
                dots: dots,
                selected: _selected,
                dragging: _dragging,
                current: _currentPoint,
                color: widget.color,
                errorColor: widget.errorColor,
                error: _error,
              ),
              size: Size(w, w),
              child: Stack(
                children: [
                  for (int i = 0; i < dots.length; i++)
                    Positioned(
                      left: dots[i].dx - 28,
                      top: dots[i].dy - 28,
                      child: GestureDetector(
                        onPanUpdate: (d) {
                          if (!_selected.contains(i)) {
                            setState(() => _selected.add(i));
                          }
                        },
                        child: SizedBox(width: 56, height: 56),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> dots;
  final List<int> selected;
  final bool dragging;
  final Offset? current;
  final Color color;
  final Color errorColor;
  final bool error;
  _PatternPainter({required this.dots, required this.selected, required this.dragging, required this.current, required this.color, required this.errorColor, required this.error});

  @override
  void paint(Canvas canvas, Size size) {
    final c = error ? errorColor : color;
    final linePaint = Paint()..color = c.withOpacity(0.7)..strokeWidth = 4..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = c.withOpacity(0.2);
    final activePaint = Paint()..color = c;
    final ringPaint = Paint()..color = c.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 2;

    for (int i = 0; i < dots.length; i++) {
      canvas.drawCircle(dots[i], 14, dotPaint);
      canvas.drawCircle(dots[i], 22, ringPaint);
    }
    for (final i in selected) {
      canvas.drawCircle(dots[i], 10, activePaint);
      canvas.drawCircle(dots[i], 26, Paint()..color = c.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    for (int i = 0; i < selected.length - 1; i++) {
      canvas.drawLine(dots[selected[i]], dots[selected[i + 1]], linePaint);
    }
    if (dragging && current != null && selected.isNotEmpty) {
      canvas.drawLine(dots[selected.last], current!, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
