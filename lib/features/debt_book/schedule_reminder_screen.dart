import 'package:flutter/material.dart';
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
    _msg.text = 'تذكير بتحصيل المبلغ ${widget.currentBalance.abs().toStringAsFixed(2)} ج.م من ${widget.contact.name}';
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
      isDone: false,
      ObjectId(),
      when,
      _msg.text.trim(),
      contactId: widget.contact.id.toString(),
    );

    await ReminderRepository.add(reminder);
    await NotificationService.schedule(reminder.id.hashCode, when, widget.contact.name, _msg.text.trim());

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
