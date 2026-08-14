import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final list = List<Map<String, dynamic>>.from(jsonDecode(p.getString('notif_center') ?? '[]'));
    if (mounted) setState(() => _items = list);
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('notif_center', jsonEncode(_items));
  }

  String _time(String iso) {
    final d = DateTime.tryParse(iso) ?? DateTime.now();
    return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unread = _items.where((i) => i['read'] == false).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.notifications}${unread > 0 ? ' ($unread)' : ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () async {
              for (final i in _items) i['read'] = true;
              await _save();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'مسح الكل',
            onPressed: () async {
              _items = [];
              await _save();
              setState(() {});
            },
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 72, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('لا توجد إشعارات بعد', style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 4),
                  Text('كل حدث مهم في التطبيق هيتسجل هنا', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final n = _items[i];
                final isRead = n['read'] == true;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isRead ? null : AppTheme.primaryBlue.withOpacity(0.06),
                  child: ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.12), child: Text(n['icon'] ?? '🔔', style: const TextStyle(fontSize: 20))),
                        if (!isRead) Positioned(right: 0, top: 0, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppTheme.expenseRed, shape: BoxShape.circle))),
                      ],
                    ),
                    title: Text(n['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.w800, fontSize: 14)),
                    subtitle: Text('${n['body'] ?? ''}\n${_time(n['time'] ?? '')}', style: const TextStyle(fontSize: 12)),
                    onTap: () async {
                      _items[i]['read'] = true;
                      await _save();
                      setState(() {});
                    },
                  ),
                );
              },
            ),
    );
  }
}
