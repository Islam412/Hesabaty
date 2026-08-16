import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/more/notifications_screen.dart';
import '../services/notification_service.dart';
import '../services/account_service.dart';

class BellOverlay {
  static OverlayEntry? _entry;
  static void show(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(builder: (ctx) => const DraggableBell());
    Overlay.of(context).insert(_entry!);
  }
}

class DraggableBell extends StatefulWidget {
  const DraggableBell({super.key});
  @override
  State<DraggableBell> createState() => _DraggableBellState();
}

class _DraggableBellState extends State<DraggableBell> {
  double? _x;
  double? _y;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _loadPos();
  }

  Future<void> _loadPos() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _x = p.getDouble('bell_x');
      _y = p.getDouble('bell_y');
    });
  }

  Future<void> _savePos() async {
    final p = await SharedPreferences.getInstance();
    if (_x != null) await p.setDouble('bell_x', _x!);
    if (_y != null) await p.setDouble('bell_y', _y!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safe = MediaQuery.of(context).padding;
    final maxX = size.width - 60;
    final maxY = size.height - 140;
    final x = (_x ?? (size.width - 68)).clamp(8.0, maxX < 8 ? 8.0 : maxX).toDouble();
    final y = (_y ?? (safe.top + 60)).clamp(safe.top + 8.0, maxY < safe.top + 8 ? safe.top + 8.0 : maxY).toDouble();

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _dragging = true),
        onPanUpdate: (d) {
          setState(() {
            _x = ((_x ?? x) + d.delta.dx).clamp(8.0, maxX).toDouble();
            _y = ((_y ?? y) + d.delta.dy).clamp(safe.top + 8.0, maxY).toDouble();
          });
        },
        onPanEnd: (_) {
          setState(() => _dragging = false);
          _savePos();
        },
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          await NotificationService.refreshCache();
        },
        child: AnimatedScale(
          scale: _dragging ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF5E35B1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2E7CF6).withOpacity(_dragging ? 0.6 : 0.35), blurRadius: _dragging ? 16 : 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.notifications_active, color: Colors.white, size: 24)),
                  ValueListenableBuilder<int>(
                    valueListenable: NotificationService.unreadCountNotifier,
                    builder: (ctx, unread, _) {
                      if (unread == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
