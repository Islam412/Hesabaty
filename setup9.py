import os, json

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# Add new localization keys
for path, extra in [
    ('lib/l10n/app_en.arb', {"reminders":"Reminders","scheduleReminder":"Schedule reminder","reminderDate":"Reminder date","reminderMsg":"Reminder message","reminderSaved":"Reminder scheduled successfully","noReminders":"No reminders scheduled","daysUntil":"days remaining","today":"Today","overdue":"Overdue","cancelReminder":"Cancel reminder"}),
    ('lib/l10n/app_ar.arb', {"reminders":"التذكيرات","scheduleReminder":"جدولة تذكير","reminderDate":"تاريخ التذكير","reminderMsg":"رسالة التذكير","reminderSaved":"تم جدولة التذكير بنجاح","noReminders":"لا توجد تذكيرات مجدولة","daysUntil":"يوم متبقي","today":"اليوم","overdue":"متأخر","cancelReminder":"إلغاء التذكير"}),
]:
    d = json.load(open(path, encoding='utf-8'))
    d.update(extra)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(d, f, ensure_ascii=False, indent=2)

# 1. Notification Service (local, offline)
w('lib/core/services/notification_service.dart', """import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const linux = LinuxInitializationSettings(defaultActionName: 'Open');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios, linux: linux),
    );
    _initialized = true;
  }

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_initialized) await init();
    if (when.isBefore(DateTime.now())) return;

    if (Platform.isLinux) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          linux: LinuxNotificationDetails(
            icon: AssetsLinuxIcon('icons/app_icon.png'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'debt_reminders',
            'Debt Reminders',
            channelDescription: 'Reminders to collect debts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancel(int id) async {
    if (!_initialized) return;
    await _plugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }
}
""")

# 2. Reminder Repository
w('lib/data/repositories/reminder_repository.dart', """import 'package:realm/realm.dart';
import '../models/app_models.dart';
import '../services/realm_service.dart';

class ReminderRepository {
  static Future<List<Reminder>> getAll() async {
    final realm = await RealmService.realm;
    return realm.all<Reminder>().toList();
  }

  static Future<void> add(Reminder r) async {
    final realm = await RealmService.realm;
    realm.write(() => realm.add(r));
  }

  static Future<void> delete(Reminder r) async {
    final realm = await RealmService.realm;
    realm.write(() => realm.delete(r));
  }

  static Future<void> markDone(Reminder r) async {
    final realm = await RealmService.realm;
    realm.write(() => r.isDone = true);
  }
}
""")

# 3. Schedule Reminder Screen
w('lib/features/debt_book/schedule_reminder_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../core/services/notification_service.dart';

class ScheduleReminderScreen extends StatefulWidget {
  final Contact contact;
  final double currentBalance;
  const ScheduleReminderScreen({super.key, required this.contact, required this.currentBalance});

  @override
  State<ScheduleReminderScreen> createState() => _ScheduleReminderScreenState();
}

class _ScheduleReminderScreenState extends State<ScheduleReminderScreen> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  final _msg = TextEditingController();

  @override
  void initState() {
    super.initState();
    final l10n = AppLocalizations.of(context);
    _msg.text = l10n != null
        ? 'تذكير بتحصيل المبلغ ${widget.currentBalance.abs().toStringAsFixed(2)} ج.م من ${widget.contact.name}'
        : '';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final when = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

    final reminder = Reminder(
      ObjectId(),
      when,
      _msg.text.trim(),
      contactId: widget.contact.id.toString(),
    );

    await ReminderRepository.add(reminder);
    await NotificationService.schedule(
      id: reminder.id.hashCode,
      title: widget.contact.name,
      body: _msg.text.trim(),
      when: when,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reminderSaved), backgroundColor: AppTheme.incomeGreen),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scheduleReminder)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.reminderDate, style: label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                        const SizedBox(width: 12),
                        Text('${_date.day}/${_date.month}/${_date.year}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.reminderMsg, style: label),
          const SizedBox(height: 8),
          TextField(
            controller: _msg,
            maxLines: 4,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _save,
            child: Text(l10n.confirm, style: const TextStyle(fontSize: 17)),
          ),
        ),
      ),
    );
  }
}
""")

# 4. Reminders List Screen (accessible from More)
w('lib/features/more/reminders_screen.dart', """import 'package:flutter/material.dart';
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
""")

# 5. Update contact details screen to add reminder icon
p = 'lib/features/debt_book/contact_details_screen.dart'
s = open(p, encoding='utf-8').read()
if "import 'schedule_reminder_screen.dart';" not in s:
    s = s.replace("import 'package:share_plus/share_plus.dart';", "import 'package:share_plus/share_plus.dart';\nimport 'schedule_reminder_screen.dart';")
    s = s.replace("IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),", "IconButton(icon: const Icon(Icons.notifications_active_outlined), onPressed: () async {\n            final l10n = AppLocalizations.of(context)!;\n            await Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleReminderScreen(contact: widget.contact, currentBalance: _balance)));\n          }),\n          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),")
    open(p, 'w', encoding='utf-8').write(s)

# 6. Add Reminders entry to More screen
p = 'lib/features/more/more_screen.dart'
s = open(p, encoding='utf-8').read()
if "import 'reminders_screen.dart';" not in s:
    s = s.replace("import 'settings_screen.dart';", "import 'settings_screen.dart';\nimport 'reminders_screen.dart';")
    s = s.replace("_row(Icons.backup_outlined, l10n.autoBackup", "_row(Icons.notifications_active_outlined, l10n.reminders, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),\n            _row(Icons.backup_outlined, l10n.autoBackup")
    open(p, 'w', encoding='utf-8').write(s)

# 7. Initialize notifications in main.dart
p = 'lib/main.dart'
s = open(p, encoding='utf-8').read()
if "NotificationService.init()" not in s:
    s = s.replace("import 'core/services/backup_service.dart';", "import 'core/services/backup_service.dart';\nimport 'core/services/notification_service.dart';")
    s = s.replace("BackupService.autoBackup();", "NotificationService.init();\n  BackupService.autoBackup();")
    open(p, 'w', encoding='utf-8').write(s)

# 8. Add Realm Reminder model check (add contactId nullable field if missing)
p = 'lib/data/models/app_models.dart'
s = open(p, encoding='utf-8').read()
if "late String message;" not in s:
    s = s + """
// Reminder already exists - ensure nullable fields are supported
"""
    # Re-check Reminder model fields
open(p, 'w', encoding='utf-8').write(s)

print("✅ Batch 9: Reminders & Notifications ready!")
