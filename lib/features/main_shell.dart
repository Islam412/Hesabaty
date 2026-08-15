import 'package:flutter/material.dart';
import '../core/widgets/draggable_bell.dart';
import 'more/notifications_screen.dart';
import '../core/services/notification_service.dart';
import '../core/services/watcher_service.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'cash_book/cash_book_screen.dart';
import 'debt_book/debt_book_screen.dart';
import 'more/more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    WatcherService.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BellOverlay.show(context);
    });
  }

  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          MoreScreen(),
          CashBookScreen(),
          DebtBookScreen(),
        ],
      ),
            bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view), label: l10n.more),
          NavigationDestination(icon: const Icon(Icons.account_balance_wallet_outlined), selectedIcon: const Icon(Icons.account_balance_wallet), label: l10n.cashBook),
          NavigationDestination(icon: const Icon(Icons.auto_stories_outlined), selectedIcon: const Icon(Icons.auto_stories), label: l10n.debtBook),
        ],
      ),
    );
  }
}


class FloatingNotifBell extends StatefulWidget {
  const FloatingNotifBell({super.key});
  @override
  State<FloatingNotifBell> createState() => _FloatingNotifBellState();
}

class _FloatingNotifBellState extends State<FloatingNotifBell> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: NotificationService.unreadCount(),
      builder: (ctx, snap) {
        final unread = snap.data ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              elevation: 8,
              shadowColor: const Color(0xFF2E7CF6).withOpacity(0.4),
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                  if (mounted) setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2E7CF6), Color(0xFF5E35B1)]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: unread > 0 ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                        child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 8),
                      const Text('الإشعارات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
