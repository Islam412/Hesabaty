import 'package:flutter/material.dart';

class FlashService {
  static void show(BuildContext context, String message, {String type = 'success'}) {
    final colors = <String, Color>{
      'success': const Color(0xFF16A34A),
      'error': const Color(0xFFDC2626),
      'info': const Color(0xFF2E7CF6),
      'warning': const Color(0xFFE5A83B),
    };
    final icons = <String, IconData>{
      'success': Icons.check_circle,
      'error': Icons.error,
      'info': Icons.info,
      'warning': Icons.warning_amber_rounded,
    };
    final color = colors[type] ?? colors['success']!;
    final icon = icons[type] ?? icons['success']!;

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -80, end: 0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (ctx, offset, child) => Transform.translate(offset: Offset(0, offset), child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  static void success(BuildContext context, String msg) => show(context, msg, type: 'success');
  static void error(BuildContext context, String msg) => show(context, msg, type: 'error');
  static void info(BuildContext context, String msg) => show(context, msg, type: 'info');
  static void warning(BuildContext context, String msg) => show(context, msg, type: 'warning');
}
