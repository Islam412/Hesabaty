import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_service.dart';
import 'backup_service.dart';

enum BackupFrequency { hourly, daily, weekly, monthly }

class AutoBackupService {
  static const String _kEnabled = 'ab_enabled';
  static const String _kFrequency = 'ab_frequency';
  static const String _kHour = 'ab_hour';
  static const String _kMinute = 'ab_minute';
  static const String _kWeekDay = 'ab_weekday';
  static const String _kMonthDay = 'ab_monthday';
  static const String _kDeleteOld = 'ab_delete_old';
  static const String _kLastRun = 'ab_last_run';

  static Future<bool> isEnabled() async {
    final p = await AccPrefs.scoped();
    return p.getBool(_kEnabled) ?? false;
  }

  static Future<void> setEnabled(bool v) async {
    final p = await AccPrefs.scoped();
    await p.setBool(_kEnabled, v);
  }

  static Future<BackupFrequency> getFrequency() async {
    final p = await AccPrefs.scoped();
    final s = p.getString(_kFrequency) ?? 'daily';
    return BackupFrequency.values.firstWhere((e) => e.name == s, orElse: () => BackupFrequency.daily);
  }

  static Future<void> setFrequency(BackupFrequency f) async {
    final p = await AccPrefs.scoped();
    await p.setString(_kFrequency, f.name);
  }

  static Future<int> getHour() async {
    final p = await AccPrefs.scoped();
    return p.getInt(_kHour) ?? 3;
  }

  static Future<void> setHour(int h) async {
    final p = await AccPrefs.scoped();
    await p.setInt(_kHour, h);
  }

  static Future<int> getMinute() async {
    final p = await AccPrefs.scoped();
    return p.getInt(_kMinute) ?? 0;
  }

  static Future<void> setMinute(int m) async {
    final p = await AccPrefs.scoped();
    await p.setInt(_kMinute, m);
  }

  static Future<int> getWeekDay() async {
    final p = await AccPrefs.scoped();
    return p.getInt(_kWeekDay) ?? DateTime.friday;
  }

  static Future<void> setWeekDay(int d) async {
    final p = await AccPrefs.scoped();
    await p.setInt(_kWeekDay, d);
  }

  static Future<int> getMonthDay() async {
    final p = await AccPrefs.scoped();
    return p.getInt(_kMonthDay) ?? 1;
  }

  static Future<void> setMonthDay(int d) async {
    final p = await AccPrefs.scoped();
    await p.setInt(_kMonthDay, d);
  }

  static Future<bool> shouldDeleteOld() async {
    final p = await AccPrefs.scoped();
    return p.getBool(_kDeleteOld) ?? true;
  }

  static Future<void> setDeleteOld(bool v) async {
    final p = await AccPrefs.scoped();
    await p.setBool(_kDeleteOld, v);
  }

  static Future<DateTime?> getLastRun() async {
    final p = await AccPrefs.scoped();
    final s = p.getString(_kLastRun);
    return s == null ? null : DateTime.tryParse(s);
  }

  static Future<void> _setLastRun(DateTime d) async {
    final p = await AccPrefs.scoped();
    await p.setString(_kLastRun, d.toIso8601String());
  }

  /// فحص هل حان موعد النسخ التلقائي — يُستدعى عند فتح التطبيق
  static Future<bool> checkAndRunIfNeeded() async {
    if (!await isEnabled()) return false;
    final freq = await getFrequency();
    final hour = await getHour();
    final minute = await getMinute();
    final now = DateTime.now();
    final last = await getLastRun();

    bool shouldRun = false;
    if (last == null) {
      shouldRun = true;
    } else {
      switch (freq) {
        case BackupFrequency.hourly:
          shouldRun = now.difference(last).inHours >= 1;
          break;
        case BackupFrequency.daily:
          final target = DateTime(now.year, now.month, now.day, hour, minute);
          final lastTarget = DateTime(last.year, last.month, last.day, hour, minute);
          shouldRun = now.isAfter(target) && target.isAfter(lastTarget);
          break;
        case BackupFrequency.weekly:
          final wd = await getWeekDay();
          if (now.weekday == wd) {
            final target = DateTime(now.year, now.month, now.day, hour, minute);
            shouldRun = now.isAfter(target) && (last.isBefore(DateTime(now.year, now.month, now.day)));
          }
          break;
        case BackupFrequency.monthly:
          final md = await getMonthDay();
          if (now.day == md) {
            final target = DateTime(now.year, now.month, now.day, hour, minute);
            shouldRun = now.isAfter(target) && last.month != now.month;
          }
          break;
      }
    }

    if (shouldRun) {
      try {
        await BackupService.createBackup(auto: true);
        if (await shouldDeleteOld()) {
          await BackupService.cleanupOldBackups(keep: 5);
        }
        await _setLastRun(now);
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  static Future<DateTime?> nextScheduledTime() async {
    if (!await isEnabled()) return null;
    final freq = await getFrequency();
    final hour = await getHour();
    final minute = await getMinute();
    final now = DateTime.now();
    switch (freq) {
      case BackupFrequency.hourly:
        final next = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
        return next;
      case BackupFrequency.daily:
        var next = DateTime(now.year, now.month, now.day, hour, minute);
        if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case BackupFrequency.weekly:
        final wd = await getWeekDay();
        var daysUntil = wd - now.weekday;
        if (daysUntil < 0) daysUntil += 7;
        if (daysUntil == 0) {
          final target = DateTime(now.year, now.month, now.day, hour, minute);
          if (now.isAfter(target)) daysUntil = 7;
        }
        return DateTime(now.year, now.month, now.day + daysUntil, hour, minute);
      case BackupFrequency.monthly:
        final md = await getMonthDay();
        var next = DateTime(now.year, now.month, md, hour, minute);
        if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
          next = DateTime(now.year, now.month + 1, md, hour, minute);
        }
        return next;
    }
  }
}
