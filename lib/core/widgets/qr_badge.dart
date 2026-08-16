import 'package:flutter/material.dart';

class QrBadge extends StatelessWidget {
  final String data;
  final double size;
  const QrBadge({super.key, required this.data, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final cells = _generateMatrix(data);
    final cellSize = size / cells.length;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E0EC)),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _QrPainter(cells: cells, cellSize: cellSize),
      ),
    );
  }

  List<List<bool>> _generateMatrix(String input) {
    final n = 25;
    final m = List.generate(n, (_) => List.filled(n, false));
    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        if (i == 0 || i == 6 || j == 0 || j == 6 || (i >= 2 && i <= 4 && j >= 2 && j <= 4)) {
          m[i][j] = true;
          m[i][n - 1 - j] = true;
          m[n - 1 - i][j] = true;
        }
      }
    }
    for (int i = 8; i < n - 8; i++) { m[6][i] = i.isEven; m[i][6] = i.isEven; }
    int hash = 0;
    for (var c in input.codeUnits) hash = (hash * 31 + c) & 0xFFFFFFFF;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (m[i][j]) continue;
        if ((i < 9 && j < 9) || (i < 9 && j > n - 9) || (i > n - 9 && j < 9)) continue;
        if (i == 6 || j == 6) continue;
        hash = (hash * 1103515245 + 12345) & 0x7FFFFFFF;
        m[i][j] = (hash & 1) == 1;
      }
    }
    return m;
  }
}

class _QrPainter extends CustomPainter {
  final List<List<bool>> cells;
  final double cellSize;
  _QrPainter({required this.cells, required this.cellSize});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF16324F);
    for (int i = 0; i < cells.length; i++) {
      for (int j = 0; j < cells[i].length; j++) {
        if (cells[i][j]) {
          canvas.drawRect(Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize), paint);
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
