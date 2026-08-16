import 'package:flutter/foundation.dart';
import '../../data/services/realm_service.dart';
import 'account_service.dart';

/// نقطة مركزية لإدارة الحساب الحالي وإعادة بناء UI عند التغيير
class AccountSession {
  static final List<void Function(String?)> _listeners = [];
  static String? _currentPhone;

  /// سجل listener عشان يعرف لما الحساب يتغير
  static void addListener(void Function(String?) listener) => _listeners.add(listener);
  static void removeListener(void Function(String?) listener) => _listeners.remove(listener);

  /// يُنادى عند بدء التطبيق عشان يعرف الحساب الحالي
  static Future<void> init() async {
    _currentPhone = await AccountService.sessionPhone();
    debugPrint(' AccountSession initialized with: $_currentPhone');
  }

  /// الحساب الحالي
  static String? get currentPhone => _currentPhone;

  /// يُنادى عند أي تغيير في الحساب (login / logout / switch)
  /// 1) يغلق Realm الحالي (عشان يفتح الملف الجديد)
  /// 2) يبلغ كل المستمعين (UI هيعيد بناء نفسه)
  static Future<void> onAccountChanged(String? newPhone) async {
    final oldPhone = _currentPhone;
    if (oldPhone == newPhone) return;
    _currentPhone = newPhone;
    debugPrint('🔄 AccountSession: $oldPhone → $newPhone');

    // 1) أغلق Realm عشان يفتح الملف الجديد
    try { await RealmService.reset(); } catch (_) {}

    // 2) بلغ كل الـ listeners
    for (final l in List.of(_listeners)) {
      try { l(newPhone); } catch (e) { debugPrint('⚠️ listener error: $e'); }
    }
  }
}
