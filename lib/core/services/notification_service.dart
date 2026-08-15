import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static Future<String> _storeKey() async {
    final phone = await AccountService.sessionPhone();
    return 'notif_${phone ?? 'global'}_center';
  }

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final loc = tz.getLocation('Africa/Cairo');
        tz.setLocalLocation(loc);
      } catch (_) {}
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const linux = LinuxInitializationSettings(defaultActionName: 'فتح');
      const settings = InitializationSettings(android: android, linux: linux);
      await _plugin.initialize(settings);
      _initialized = true;
      debugPrint('🔔 NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ NotificationService init failed: $e');
    }
  }

  static Future<void> notify(String title, String body, {String icon = '🔔', bool important = true}) async {
    debugPrint('📨 Notification: $title — $body');
    // منع التكرار خلال 3 ثواني
    try {
      final p0 = await SharedPreferences.getInstance();
      final l0 = List<Map<String, dynamic>>.from(jsonDecode(p0.getString(await _storeKey()) ?? '[]'));
      if (l0.isNotEmpty && l0[0]['title'] == title && l0[0]['body'] == body) {
        final t0 = DateTime.tryParse(l0[0]['time'] ?? '');
        if (t0 != null && DateTime.now().difference(t0).inSeconds < 3) return;
      }
    } catch (_) {}
    // 1) محاولة إرسال إشعار للنظام
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails('hesabaty_main', 'حساباتي', channelDescription: 'إشعارات التطبيق', importance: Importance.high, priority: Priority.high),
        linux: LinuxNotificationDetails(),
      );
      await _plugin.show(DateTime.now().millisecondsSinceEpoch % 1000000, '$icon $title', body, details);
      debugPrint('✅ System notification sent');
    } catch (e) {
      debugPrint('⚠️ System notification failed (will save to center): $e');
    }
    // 2) حفظ في مركز الإشعارات (دائمًا)
    if (important) {
      try {
        final p = await SharedPreferences.getInstance();
        final raw = p.getString(await _storeKey()) ?? '[]';
        final decoded = jsonDecode(raw);
        final list = decoded is List ? List<Map<String, dynamic>>.from(decoded) : <Map<String, dynamic>>[];
        list.insert(0, {
          'title': title,
          'body': body,
          'icon': icon,
          'time': DateTime.now().toIso8601String(),
          'read': false,
        });
        if (list.length > 200) list.removeRange(200, list.length);
        await p.setString(await _storeKey(), jsonEncode(list));
        debugPrint('💾 Saved to notif_center (total: ${list.length})');
      } catch (e) {
        debugPrint('❌ Failed to save to center: $e');
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(await _storeKey()) ?? '[]';
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {}
    return [];
  }

  static Future<int> unreadCount() async {
    final list = await getAll();
    return list.where((i) => i['read'] == false).length;
  }

  static Future<void> markAllRead() async {
    final list = await getAll();
    for (final i in list) {
      i['read'] = true;
    }
    final p = await SharedPreferences.getInstance();
    await p.setString(await _storeKey(), jsonEncode(list));
  }

  static Future<void> clearAll() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(await _storeKey(), '[]');
  }

  static Future<void> schedule(int id, DateTime when, String title, String body) async {
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails('hesabaty_main', 'حساباتي', channelDescription: 'إشعارات', importance: Importance.high, priority: Priority.high),
        linux: LinuxNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('⚠️ schedule failed, sending immediate: $e');
      await notify(title, body, icon: '⏰');
    }
  }

  static Future<void> cancel(int id) async {
    try {
      await init();
      await _plugin.cancel(id);
    } catch (_) {}
  }
}
