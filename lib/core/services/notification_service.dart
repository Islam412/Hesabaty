import 'dart:convert';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const linux = LinuxInitializationSettings(defaultActionName: 'فتح الإشعار');
      const settings = InitializationSettings(android: android, linux: linux);
      try { tzdata.initializeTimeZones(); final loc = tz.getLocation('Africa/Cairo'); tz.setLocalLocation(loc); } catch (_) {}
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {}
  }

  static Future<void> notify(String title, String body, {String icon = '🔔', bool important = true}) async {
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails('hesabaty_main', 'إشعارات حساباتي', channelDescription: 'كل إشعارات التطبيق', importance: Importance.high, priority: Priority.high),
        linux: LinuxNotificationDetails(),
      );
      await _plugin.show(DateTime.now().millisecondsSinceEpoch % 1000000, '$icon $title', body, details);
    } catch (_) {}
    if (important) {
      try {
        final p = await SharedPreferences.getInstance();
        final list = List<Map<String, dynamic>>.from(jsonDecode(p.getString('notif_center') ?? '[]'));
        list.insert(0, {'title': title, 'body': body, 'icon': icon, 'time': DateTime.now().toIso8601String(), 'read': false});
        if (list.length > 100) list.removeRange(100, list.length);
        await p.setString('notif_center', jsonEncode(list));
      } catch (_) {}
    }
  }

  static Future<int> unreadCount() async {
    final p = await SharedPreferences.getInstance();
    final list = List<Map<String, dynamic>>.from(jsonDecode(p.getString('notif_center') ?? '[]'));
    return list.where((i) => i['read'] == false).length;
  }

  static Future<void> schedule(int id, DateTime when, String title, String body) async {
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails('hesabaty_main', 'إشعارات حساباتي', channelDescription: 'كل إشعارات التطبيق', importance: Importance.high, priority: Priority.high),
        linux: LinuxNotificationDetails(),
      );
      await _plugin.zonedSchedule(id, title, body, tz.TZDateTime.from(when, tz.local), details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    } catch (_) {
      try {
        await notify(title, body, icon: '⏰');
      } catch (_) {}
    }
  }

  static Future<void> cancel(int id) async {
    try {
      await init();
      await _plugin.cancel(id);
    } catch (_) {}
  }
}
