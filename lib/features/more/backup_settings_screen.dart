import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../core/services/auto_backup_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/share_service.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});
  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool _enabled = false;
  BackupFrequency _freq = BackupFrequency.daily;
  int _hour = 3;
  int _minute = 0;
  int _weekDay = DateTime.friday;
  int _monthDay = 1;
  bool _deleteOld = true;
  DateTime? _lastRun;
  DateTime? _nextRun;
  List<File> _backups = [];
  String _path = '';
  bool _busy = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _enabled = await AutoBackupService.isEnabled();
    _freq = await AutoBackupService.getFrequency();
    _hour = await AutoBackupService.getHour();
    _minute = await AutoBackupService.getMinute();
    _weekDay = await AutoBackupService.getWeekDay();
    _monthDay = await AutoBackupService.getMonthDay();
    _deleteOld = await AutoBackupService.shouldDeleteOld();
    _lastRun = await AutoBackupService.getLastRun();
    _nextRun = await AutoBackupService.nextScheduledTime();
    _backups = await BackupService.listBackups();
    _path = await BackupService.backupPath();
    if (!mounted) return;
    setState(() => _loaded = true);
  }

  String _dayName(int d, AppLocalizations l10n) {
    const map = {1: 'monday', 2: 'tuesday', 3: 'wednesday', 4: 'thursday', 5: 'friday', 6: 'saturday', 7: 'sunday'};
    final key = map[d] ?? 'friday';
    switch (key) {
      case 'monday': return l10n.monday;
      case 'tuesday': return l10n.tuesday;
      case 'wednesday': return l10n.wednesday;
      case 'thursday': return l10n.thursday;
      case 'friday': return l10n.friday;
      case 'saturday': return l10n.saturday;
      case 'sunday': return l10n.sunday;
    }
    return '';
  }

  String _freqLabel(AppLocalizations l10n) {
    switch (_freq) {
      case BackupFrequency.hourly: return l10n.hourly;
      case BackupFrequency.daily: return l10n.daily;
      case BackupFrequency.weekly: return l10n.weekly;
      case BackupFrequency.monthly: return l10n.monthly;
    }
  }

  Future<void> _backupNow() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await BackupService.createBackup();
      if (_deleteOld) await BackupService.cleanupOldBackups(keep: 5);
      if (_enabled) {
        final p = await SharedPreferences.getInstance();
        await p.setString('ab_last_run', DateTime.now().toIso8601String());
      }
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.backupCreated), backgroundColor: AppTheme.incomeGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.expenseRed));
    }
    setState(() => _busy = false);
  }

  Future<void> _restore(File f) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreBackup),
        content: Text(l10n.confirmRestore),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.confirm)),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await BackupService.restore(f);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.backupRestored), backgroundColor: AppTheme.incomeGreen));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: AppTheme.expenseRed));
    }
    setState(() => _busy = false);
  }

  Future<void> _shareBackup(File f) async {
    await ShareService.shareReceiptImage(context, f.path, 'نسخة احتياطية - حساباتي');
  }

  Future<void> _deleteBackup(File f) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف'),
        content: const Text('تأكيد حذف النسخة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.expenseRed), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await f.delete();
      await _load();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== تفعيل/إيقاف =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue.withOpacity(0.1), AppTheme.primaryBlue.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.autoBackup, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  subtitle: Text(l10n.autoBackupDesc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  value: _enabled,
                  onChanged: (v) async {
                    await AutoBackupService.setEnabled(v);
                    setState(() => _enabled = v);
                    await _load();
                  },
                ),
                if (_enabled && _nextRun != null) ...[
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.backupScheduled, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      Text(DateFormat('yyyy-MM-dd HH:mm').format(_nextRun!), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ===== التكرار =====
          if (_enabled) ...[
            const SizedBox(height: 16),
            Text(l10n.backupFrequency, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...BackupFrequency.values.map((f) {
              final sel = _freq == f;
              IconData icon;
              switch (f) {
                case BackupFrequency.hourly: icon = Icons.access_time; break;
                case BackupFrequency.daily: icon = Icons.today; break;
                case BackupFrequency.weekly: icon = Icons.calendar_view_week; break;
                case BackupFrequency.monthly: icon = Icons.calendar_month; break;
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: sel ? AppTheme.primaryBlue.withOpacity(0.08) : null,
                child: RadioListTile<BackupFrequency>(
                  secondary: Icon(icon, color: sel ? AppTheme.primaryBlue : Colors.grey),
                  title: Text(_freqLabelFor(f, l10n), style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                  value: f,
                  groupValue: _freq,
                  onChanged: (v) async {
                    if (v != null) {
                      await AutoBackupService.setFrequency(v);
                      setState(() => _freq = v);
                      await _load();
                    }
                  },
                ),
              );
            }),

            // ===== الوقت =====
            const SizedBox(height: 16),
            Text(l10n.backupTime, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule, color: AppTheme.primaryBlue),
                title: Text('${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}', textDirection: ui.TextDirection.ltr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                onTap: () async {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _hour, minute: _minute));
                  if (t != null) {
                    await AutoBackupService.setHour(t.hour);
                    await AutoBackupService.setMinute(t.minute);
                    setState(() { _hour = t.hour; _minute = t.minute; });
                    await _load();
                  }
                },
              ),
            ),

            // ===== اليوم للأسبوعي =====
            if (_freq == BackupFrequency.weekly) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event, color: AppTheme.primaryBlue),
                  title: Text(_dayName(_weekDay, l10n), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                  onTap: () async {
                    final d = await showDialog<int>(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: Text(l10n.selectDay),
                        children: [1,2,3,4,5,6,7].map((i) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, i),
                          child: Text(_dayName(i, l10n)),
                        )).toList(),
                      ),
                    );
                    if (d != null) {
                      await AutoBackupService.setWeekDay(d);
                      setState(() => _weekDay = d);
                      await _load();
                    }
                  },
                ),
              ),
            ],

            // ===== اليوم للشهري =====
            if (_freq == BackupFrequency.monthly) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                  title: Text('يوم $_monthDay من الشهر', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue),
                  onTap: () async {
                    final d = await showDialog<int>(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                        title: Text(l10n.selectDay),
                        children: List.generate(28, (i) => i + 1).map((i) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, i),
                          child: Text('يوم $i'),
                        )).toList(),
                      ),
                    );
                    if (d != null) {
                      await AutoBackupService.setMonthDay(d);
                      setState(() => _monthDay = d);
                      await _load();
                    }
                  },
                ),
              ),
            ],

            // ===== حذف النسخ القديمة =====
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.delete_sweep, color: AppTheme.expenseRed),
                title: Text(l10n.deleteOldBackups, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.deleteOldBackupsDesc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                value: _deleteOld,
                onChanged: (v) async {
                  await AutoBackupService.setDeleteOld(v);
                  setState(() => _deleteOld = v);
                },
              ),
            ),
          ],

          // ===== معلومات آخر نسخة =====
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.incomeGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.incomeGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.incomeGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.lastBackup, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text(_lastRun == null ? l10n.never : DateFormat('yyyy-MM-dd HH:mm').format(_lastRun!), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== أزرار =====
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _busy ? null : _backupNow,
            icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload),
            label: Text(l10n.backupNow, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () async {
              await launchUrl(Uri.parse('file://$_path'), mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.folder_open),
            label: Text('${l10n.openFolder}: $_path', overflow: TextOverflow.ellipsis, textDirection: ui.TextDirection.ltr, style: const TextStyle(fontSize: 12)),
          ),

          // ===== قائمة النسخ =====
          const SizedBox(height: 20),
          Text(l10n.restoreBackup, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_backups.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text(l10n.noBackups, style: TextStyle(color: Colors.grey.shade500))),
              ),
            )
          else
            ..._backups.map((f) {
              final name = f.path.split('/').last;
              final stat = f.statSync();
              final size = (stat.size / 1024).toStringAsFixed(1);
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.1), child: const Icon(Icons.backup, color: AppTheme.primaryBlue)),
                  title: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textDirection: ui.TextDirection.ltr, overflow: TextOverflow.ellipsis),
                  subtitle: Text('$size KB • ${DateFormat('yyyy-MM-dd HH:mm').format(stat.modified)}', textDirection: ui.TextDirection.ltr, style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.download, size: 20, color: AppTheme.incomeGreen), onPressed: () => _restore(f), tooltip: l10n.restoreBackup),
                      IconButton(icon: const Icon(Icons.share, size: 20, color: AppTheme.primaryBlue), onPressed: () => _shareBackup(f)),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.expenseRed), onPressed: () => _deleteBackup(f)),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _freqLabelFor(BackupFrequency f, AppLocalizations l10n) {
    switch (f) {
      case BackupFrequency.hourly: return l10n.hourly;
      case BackupFrequency.daily: return l10n.daily;
      case BackupFrequency.weekly: return l10n.weekly;
      case BackupFrequency.monthly: return l10n.monthly;
    }
  }
}

