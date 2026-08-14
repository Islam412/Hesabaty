import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../core/services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});
  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await ReminderRepository.getAll();
    all.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    setState(() => _items = all);
  }

  String _label(DateTime d) {
    final now = DateTime.now();
    final diff = d.difference(now).inDays;
    if (diff < 0) return AppLocalizations.of(context)!.overdue;
    if (diff == 0) return AppLocalizations.of(context)!.today;
    return '$diff ${AppLocalizations.of(context)!.daysUntil}';
  }

  Color _color(DateTime d) {
    final diff = d.difference(DateTime.now()).inDays;
    if (diff < 0) return AppTheme.expenseRed;
    if (diff == 0) return Colors.orange;
    return AppTheme.incomeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminders)),
      body: _items.isEmpty
          ? Center(child: Text(l10n.noReminders, style: TextStyle(color: Colors.grey.shade500)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final r = _items[i];
                final c = _color(r.dueDate);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: c.withOpacity(0.15),
                      child: Icon(Icons.notifications_active, color: c),
                    ),
                    title: Text(r.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${r.dueDate.day}/${r.dueDate.month}/${r.dueDate.year}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text(_label(r.dueDate), style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    onLongPress: () async {
                      await ReminderRepository.delete(r);
                      await NotificationService.cancel(r.id.hashCode);
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
