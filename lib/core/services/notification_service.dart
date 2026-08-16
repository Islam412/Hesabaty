import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'account_service.dart';
import '../../data/models/notification_item.dart';

/// خدمة الإشعارات — كل حساب معزول + ValueNotifier للتحديث اللحظي بدون polling
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// ValueNotifier — widgets تستمع هنا مباشرة (بدون Timer.periodic)
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  /// In-memory cache — بدل ما نقرأ من SharedPreferences كل مرة
  static List<NotificationItem> _cache = [];
  static String? _cachedPhone;

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

  static Future<String> _storeKey() async {
    final phone = await AccountService.sessionPhone() ?? 'global';
    return 'notif_${phone}_items';
  }

  /// يُحمّل الإشعارات في الـ cache + يحدث الـ ValueNotifier
  static Future<void> refreshCache() async {
    try {
      final phone = await AccountService.sessionPhone() ?? 'global';
      debugPrint('🔍 refreshCache for phone: $phone (cached: $_cachedPhone)');
      if (_cachedPhone != phone) {
        _cache = [];
        _cachedPhone = phone;
      }
      final key = await _storeKey();
      final p = await AccPrefs.scoped();
      final raw = p.getString(key);
      debugPrint('🔍 raw from prefs: ${raw?.substring(0, raw.length.clamp(0, 80)) ?? "null"}');
      if (raw == null || raw.isEmpty) {
        _cache = [];
      } else {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _cache = decoded.map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        }
      }
      final unread = _cache.where((i) => !i.read).length;
      if (unreadCountNotifier.value != unread) {
        unreadCountNotifier.value = unread;
      }
      debugPrint('✅ refreshCache done: ${_cache.length} items, $unread unread');
    } catch (e, st) {
      debugPrint('❌ refreshCache error: $e');
      debugPrint('Stack: $st');
      _cache = [];
    }
  }

  /// يُرسل إشعار + يحفظه + يُحدّث الـ cache والـ notifier فورًا
  static Future<void> notify(String title, String body, {String icon = '🔔', bool important = true, String? link}) async {
    try {
      final phone = await AccountService.sessionPhone() ?? 'global';
      debugPrint('📨 notify called: [$title] for $phone');
      
      // منع التكرار خلال 3 ثواني (من الـ cache)
      if (_cache.isNotEmpty && _cache.first.title == title && _cache.first.body == body) {
        if (DateTime.now().difference(_cache.first.time).inSeconds < 3) {
          debugPrint('⏭️  Skipped (duplicate within 3s)');
          return;
        }
      }

      // إشعار نظام
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

      // حفظ في cache + SharedPreferences + ValueNotifier
      if (important) {
        try {
          final item = NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            body: body,
            icon: icon,
            time: DateTime.now(),
            read: false,
            link: link,
          );
          _cache.insert(0, item);
          if (_cache.length > 200) _cache.removeRange(200, _cache.length);
          final key = await _storeKey();
          final p = await AccPrefs.scoped();
          await p.setString(key, jsonEncode(_cache.map((e) => e.toJson()).toList()));
          // تحديث فوري للـ ValueNotifier
          unreadCountNotifier.value = _cache.where((i) => !i.read).length;
          debugPrint('💾 Saved [$phone] (total: ${_cache.length})');
        } catch (e) {
          debugPrint('❌ Failed to save: $e');
        }
      }
    } catch (e, st) {
      debugPrint('❌ notify FATAL error: $e');
      debugPrint('Stack: $st');
    }
  }

  /// كل الإشعارات من الـ cache (سريع جدًا — مفيش I/O)
  static Future<List<NotificationItem>> getAll() async {
    final phone = await AccountService.sessionPhone() ?? 'global';
    if (_cachedPhone != phone) await refreshCache();
    return List.from(_cache);
  }

  static Future<int> unreadCount() async {
    final phone = await AccountService.sessionPhone() ?? 'global';
    if (_cachedPhone != phone) await refreshCache();
    return _cache.where((i) => !i.read).length;
  }

  static Future<void> markAllRead() async {
    for (final i in _cache) i.read = true;
    final key = await _storeKey();
    final p = await AccPrefs.scoped();
    await p.setString(key, jsonEncode(_cache.map((e) => e.toJson()).toList()));
    unreadCountNotifier.value = 0;
  }

  static Future<void> clearAll() async {
    _cache = [];
    final key = await _storeKey();
    final p = await AccPrefs.scoped();
    await p.setString(key, '[]');
    unreadCountNotifier.value = 0;
  }

  /// يُنادى عند تغيير الحساب — يمسح الـ cache ويعيد تحميل
  static Future<void> onAccountChanged() async {
    debugPrint('🔄 NotificationService.onAccountChanged: clearing cache');
    _cachedPhone = null;
    _cache = [];
    await refreshCache();
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
