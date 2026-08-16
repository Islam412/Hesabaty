import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrBadge extends StatelessWidget {
  final String data;
  final double size;
  const QrBadge({super.key, required this.data, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7E0EC)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16324F),
      ),
    );
  }
}
