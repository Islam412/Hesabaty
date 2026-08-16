import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'account_session.dart';
import 'notification_service.dart';

class WatcherService {
  static bool _started = false;
  static final List<StreamSubscription> _subs = [];
  static Realm? _watchedRealm;
  static bool _listeningToAccount = false;

  static String _dt(DateTime d) => DateFormat('yyyy/MM/dd  HH:mm').format(d);

  /// يوقف كل الاشتراكات
  static void _stop() {
    final n = _subs.length;
    for (final sub in _subs) {
      try { sub.cancel(); } catch (_) {}
    }
    _subs.clear();
    _watchedRealm = null;
    _started = false;
    debugPrint('🛑 Watcher stopped ($n subs cleared)');
  }

  /// يُنادى تلقائيًا عند أي تغيير في الحساب
  static Future<void> _onAccountChanged(String? _) async {
    debugPrint('🔄 Watcher reacting to account change...');
    _stop();
    // ننتظر شوية عشان RealmService يفتح الملف الجديد
    await Future.delayed(const Duration(milliseconds: 100));
    await start();
  }

  /// واجهة قديمة — تحافظ على التوافق
  static Future<void> restart() => _onAccountChanged(null);

  static Future<void> start() async {
    // سجل listener للحساب مرة واحدة
    if (!_listeningToAccount) {
      AccountSession.addListener(_onAccountChanged);
      _listeningToAccount = true;
      debugPrint('👂 Watcher listening to account changes');
    }

    if (_started) {
      // تحقق: لو الـ Realm اتغير (حساب جديد) → أعد الاشتراك
      try {
        final current = await RealmService.realm;
        if (identical(_watchedRealm, current)) return;
        debugPrint('🔀 Realm instance changed — re-subscribing');
        _stop();
      } catch (e) {
        debugPrint('⚠️ Could not get realm in start(): $e');
        return;
      }
    }

    try {
      final realm = await RealmService.realm;
      _started = true;
      _watchedRealm = realm;
      debugPrint('👁️ Watcher subscribing to realm at: ${realm.config.path}');

      // ===== دفتر الديون =====
      final debt = realm.all<DebtTransaction>();
      _subs.add(debt.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final t = debt[i];
            if (t.status == 'deleted') continue;
            String contactName = 'جهة غير معروفة';
            try {
              final contact = realm.query<Contact>('id == \$0', [ObjectId.fromHexString(t.contactId)]).first;
              contactName = contact?.name ?? 'جهة غير معروفة';
            } catch (_) {}
            final received = t.type == 'received';
            final icon = received ? '💰' : '💸';
            final title = received ? 'تم القبض من $contactName' : 'تم الدفع إلى $contactName';
            final body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}\nالتاريخ: ${_dt(t.date)}${(t.note ?? '').isNotEmpty ? '\nملاحظة: ${t.note}' : ''}';
            await NotificationService.notify(title, body, icon: icon);
          } catch (e) { debugPrint('⚠️ debt err: $e'); }
        }
      }));

      // ===== دفتر النقدية =====
      final cash = realm.all<CashTransaction>();
      _subs.add(cash.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final t = cash[i];
            if (t.status == 'deleted') continue;
            final isIn = t.type.contains('in');
            final icon = isIn ? '💵' : '💸';
            final title = isIn ? 'دخل نقدي جديد' : 'مصروف نقدي جديد';
            final body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}\nالنوع: ${isIn ? "دخل" : "مصروف"}\nالتاريخ: ${_dt(t.date)}${(t.note ?? '').isNotEmpty ? '\nملاحظة: ${t.note}' : ''}';
            await NotificationService.notify(title, body, icon: icon);
          } catch (e) { debugPrint('⚠️ cash err: $e'); }
        }
      }));

      // ===== المحفظة =====
      final wtx = realm.all<WalletTransaction>();
      _subs.add(wtx.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final t = wtx[i];
            if (t.status != 'success') continue;
            String title, icon, body;
            if (t.type == 'topup') { title = 'تم شحن المحفظة'; icon = '👛'; body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}'; }
            else if (t.type == 'bill') { title = 'تم دفع فاتورة'; icon = '🧾'; body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}'; }
            else { title = 'تم تحويل مبلغ'; icon = '💸'; body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}'; }
            await NotificationService.notify(title, body, icon: icon);
          } catch (e) { debugPrint('⚠️ wallet err: $e'); }
        }
      }));

      // ===== البطاقات =====
      final cards = realm.all<LinkedCard>();
      _subs.add(cards.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final c = cards[i];
            await NotificationService.notify('تم إضافة بطاقة جديدة 💳', 'البنك: ${c.bank ?? 'غير محدد'}\nالرقم: •••• ${c.last4}', icon: '💳');
          } catch (e) { debugPrint('⚠️ card err: $e'); }
        }
      }));

      // ===== المنتجات =====
      final products = realm.all<Product>();
      _subs.add(products.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final p = products[i];
            await NotificationService.notify('منتج جديد 📦', '${p.name} — ${p.sku}', icon: '📦');
          } catch (e) { debugPrint('⚠️ product err: $e'); }
        }
      }));

      // ===== حركات المخزون =====
      final moves = realm.all<StockMovement>();
      _subs.add(moves.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final m = moves[i];
            String pname = 'منتج';
            try { final p = realm.query<Product>('id == \$0', [ObjectId.fromHexString(m.productId)]).first; pname = p?.name ?? 'منتج'; } catch (_) {}
            final isIn = m.type == 'in';
            await NotificationService.notify(isIn ? 'إضافة لمخزون $pname' : 'سحب من مخزون $pname', 'الكمية: ${m.quantity.toStringAsFixed(0)}', icon: '📦');
          } catch (e) { debugPrint('⚠️ move err: $e'); }
        }
      }));

      // ===== الموظفون =====
      final staff = realm.all<Staff>();
      _subs.add(staff.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final s = staff[i];
            await NotificationService.notify('موظف جديد 👥', '${s.name} — ${s.role}', icon: '👥');
          } catch (e) { debugPrint('⚠️ staff err: $e'); }
        }
      }));

      // ===== رواتب =====
      final pays = realm.all<StaffPayment>();
      _subs.add(pays.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final p = pays[i];
            String name = 'موظف';
            try { final s = realm.query<Staff>('id == \$0', [ObjectId.fromHexString(p.staffId)]).first; name = s?.name ?? 'موظف'; } catch (_) {}
            await NotificationService.notify('صرف راتب لـ $name 💰', '${p.amount.toStringAsFixed(2)} ${Cur.v}', icon: '💰');
          } catch (e) { debugPrint('⚠️ pay err: $e'); }
        }
      }));

      // ===== حضور =====
      final att = realm.all<StaffAttendance>();
      _subs.add(att.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final a = att[i];
            String name = 'موظف';
            try { final s = realm.query<Staff>('id == \$0', [ObjectId.fromHexString(a.staffId)]).first; name = s?.name ?? 'موظف'; } catch (_) {}
            final label = a.status == 'present' ? 'حضور' : (a.status == 'absent' ? 'غياب' : 'إجازة');
            final icon = a.status == 'present' ? '✅' : (a.status == 'absent' ? '🚨' : '🏖️');
            await NotificationService.notify('$label: $name', _dt(a.date), icon: icon);
          } catch (e) { debugPrint('⚠️ att err: $e'); }
        }
      }));

      debugPrint('✅ Watcher active — ${_subs.length} streams on ${realm.config.path}');
    } catch (e, st) {
      debugPrint('❌ Watcher failed: $e');
      debugPrint('Stack: $st');
      _started = false;
    }
  }
}
