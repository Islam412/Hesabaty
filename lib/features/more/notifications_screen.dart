import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await NotificationService.getAll();
    if (mounted) setState(() { _items = list; _loading = false; });
  }

  String _time(String iso) {
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Color _colorFor(String? icon) {
    switch (icon) {
      case '💰': case '💵': case '💸': return AppTheme.incomeGreen;
      case '🚨': case '⚠️': return AppTheme.expenseRed;
      case '📦': return const Color(0xFFE5A83B);
      case '👥': case '👤': return const Color(0xFF7C4DFF);
      case '🔐': case '👋': return AppTheme.primaryBlue;
      default: return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = _items.where((i) => i['read'] == false).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.notifications}${unread > 0 ? ' ($unread)' : ''}'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'تحديد الكل كمقروء',
              onPressed: () async {
                await NotificationService.markAllRead();
                _load();
              },
            ),
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'مسح الكل',
              onPressed: () async {
                final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('مسح كل الإشعارات؟'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('مسح'))],
                ));
                if (ok == true) {
                  await NotificationService.clearAll();
                  _load();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('لا توجد إشعارات بعد', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text('كل عملية مهمة في التطبيق هتظهر هنا', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final n = _items[i];
                      final isRead = n['read'] == true;
                      final c = _colorFor(n['icon']);
                      return Dismissible(
                        key: ValueKey('${n['time']}_$i'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: AppTheme.expenseRed, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          _items.removeAt(i);
                          final p = await SharedPreferences.getInstance();
                          await p.setString('notif_center', jsonEncode(_items));
                          if (mounted) setState(() {});
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isRead ? null : c.withOpacity(0.06),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              if (!isRead) {
                                _items[i]['read'] = true;
                                final p = await SharedPreferences.getInstance();
                                await p.setString('notif_center', jsonEncode(_items));
                                setState(() {});
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                        child: Center(child: Text(n['icon'] ?? '🔔', style: const TextStyle(fontSize: 22))),
                                      ),
                                      if (!isRead)
                                        Positioned(
                                          right: 0, top: 0,
                                          child: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.expenseRed, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.w800, fontSize: 14)),
                                        const SizedBox(height: 3),
                                        Text(n['body'] ?? '', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.4)),
                                        const SizedBox(height: 4),
                                        Text(_time(n['time'] ?? ''), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await NotificationService.notify('🧪 إشعار تجريبي', 'لو شايف الرسالة دي فخدمة الإشعارات شغالة!', icon: '✅');
          _load();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال إشعار تجريبي ✓')));
        },
        icon: const Icon(Icons.send),
        label: const Text('إرسال تجريبي'),
      ),
    );
  }
}
