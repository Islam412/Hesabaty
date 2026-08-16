import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'account_service.dart';
import '../../data/models/notification_item.dart';

/// خدمة الإشعارات — كل حساب له إشعاراته الخاصة المعزولة
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      try { tz.setLocalLocation(tz.getLocation('Africa/Cairo')); } catch (_) {}
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const linux = LinuxInitializationSettings(defaultActionName: 'فتح');
      await _plugin.initialize(const InitializationSettings(android: android, linux: linux));
      _initialized = true;
      debugPrint('🔔 NotificationService initialized');
    } catch (e) {
      debugPrint('❌ NotificationService init failed: $e');
    }
  }

  /// مفتاح SharedPreferences معزول لكل حساب
  static Future<String> _storeKey() async {
    final phone = await AccountService.sessionPhone() ?? 'global';
    return 'notif_${phone}_items';
  }

  /// يُرسل إشعار + يحفظه للحساب الحالي فقط
  static Future<void> notify(String title, String body, {String icon = '🔔', bool important = true, String? link}) async {
    debugPrint('📨 Notification [$title] for account: ${await AccountService.sessionPhone() ?? 'global'}');
    final phone = await AccountService.sessionPhone() ?? 'global';

    // 1) منع التكرار خلال 3 ثواني
    try {
      final list = await getAll();
      if (list.isNotEmpty && list.first.title == title && list.first.body == body) {
        if (DateTime.now().difference(list.first.time).inSeconds < 3) return;
      }
    } catch (_) {}

    // 2) إشعار نظام
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails('hesabaty_main', 'حساباتي', channelDescription: 'إشعارات التطبيق', importance: Importance.high, priority: Priority.high),
        linux: LinuxNotificationDetails(),
      );
      await _plugin.show(DateTime.now().millisecondsSinceEpoch % 1000000, '$icon $title', body, details);
      debugPrint('✅ System notification sent');
    } catch (e) {
      debugPrint('⚠️ System notification failed: $e');
    }

    // 3) حفظ للحساب الحالي فقط (معزول)
    if (important) {
      try {
        final list = await getAll();
        final item = NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: body,
          icon: icon,
          time: DateTime.now(),
          read: false,
          link: link,
        );
        list.insert(0, item);
        if (list.length > 200) list.removeRange(200, list.length);
        final key = await _storeKey();
        final p = await AccPrefs.scoped();
        await p.setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));
        debugPrint('💾 Saved to account [$phone] (total: ${list.length})');
      } catch (e) {
        debugPrint('❌ Failed to save: $e');
      }
    }
  }

  /// كل الإشعارات للحساب الحالي فقط
  static Future<List<NotificationItem>> getAll() async {
    try {
      final key = await _storeKey();
      final p = await AccPrefs.scoped();
      final raw = p.getString(key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (_) {}
    return [];
  }

  /// عدد غير المقروء للحساب الحالي فقط
  static Future<int> unreadCount() async {
    final list = await getAll();
    return list.where((i) => !i.read).length;
  }

  /// علم كل إشعارات الحساب الحالي كمقروءة
  static Future<void> markAllRead() async {
    final list = await getAll();
    for (final i in list) i.read = true;
    final key = await _storeKey();
    final p = await AccPrefs.scoped();
    await p.setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// امسح إشعارات الحساب الحالي فقط
  static Future<void> clearAll() async {
    final key = await _storeKey();
    final p = await AccPrefs.scoped();
    await p.setString(key, '[]');
  }

  static Future<void> schedule(int id, DateTime when, String title, String body) async {
    try {
      await init();
      const details = NotificationDetails(
        android: AndroidNotificationDetails('hesabaty_main', 'حساباتي', channelDescription: 'إشعارات', importance: Importance.high, priority: Priority.high),
        linux: LinuxNotificationDetails(),
      );
      await _plugin.zonedSchedule(
        id, title, body,
        tz.TZDateTime.from(when, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('⚠️ schedule failed: $e');
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
