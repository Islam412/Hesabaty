import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'notification_service.dart';

class WatcherService {
  static bool _started = false;

  static Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final realm = await RealmService.realm;

      // ===== دفتر النقدية =====
      final cash = realm.all<CashTransaction>();
      cash.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final t = cash[i];
            if (t.status == 'deleted') continue;
            final isIn = t.type.contains('in');
            NotificationService.notify(
              isIn ? 'دخل نقدي 💵' : 'مصروف نقدي 💸',
              '${t.amount.toStringAsFixed(2)} ${Cur.v}${(t.note ?? '').isNotEmpty ? ' — ${t.note}' : ''}',
              icon: isIn ? '💵' : '💸',
            );
          } catch (_) {}
        }
      });

      // ===== دفتر الديون =====
      final debt = realm.all<DebtTransaction>();
      debt.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final t = debt[i];
            if (t.status == 'deleted') continue;
            String name = '';
            try {
              name = (realm.query<Contact>('id == \$0', [t.contactId]).first?.name) ?? '';
            } catch (_) {}
            final received = t.type == 'received';
            NotificationService.notify(
              received ? 'تم القبض 💰' : 'تم الدفع 💸',
              '${name.isNotEmpty ? '$name — ' : ''}${t.amount.toStringAsFixed(2)} ${Cur.v}${(t.note ?? '').isNotEmpty ? ' — ${t.note}' : ''}',
              icon: received ? '💰' : '💸',
            );
          } catch (_) {}
        }
      });

      // ===== المحفظة التجارية =====
      final wtx = realm.all<WalletTransaction>();
      wtx.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final t = wtx[i];
            if (t.status != 'success') continue;
            String title;
            String icon;
            if (t.type == 'topup') { title = 'تم شحن المحفظة'; icon = '👛'; }
            else if (t.type == 'bill') { title = 'تم دفع فاتورة'; icon = '🧾'; }
            else { title = 'تم إرسال مبلغ'; icon = '💸'; }
            NotificationService.notify(title, '${t.amount.toStringAsFixed(2)} ${Cur.v}', icon: icon);
          } catch (_) {}
        }
      });

      // ===== البطاقات =====
      final cards = realm.all<LinkedCard>();
      cards.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final c = cards[i];
            NotificationService.notify('بطاقة جديدة', 'تم ربط ${c.brand} •••• ${c.last4}', icon: '💳');
          } catch (_) {}
        }
      });

      // ===== المخزون =====
      final products = realm.all<Product>();
      products.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final p = products[i];
            NotificationService.notify('منتج جديد', '${p.name} — مخزون ${p.stock.toStringAsFixed(0)}', icon: '📦');
          } catch (_) {}
        }
      });

      final moves = realm.all<StockMovement>();
      moves.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final m = moves[i];
            String pname = '';
            try { pname = (realm.query<Product>('id == \$0', [m.productId]).first?.name) ?? ''; } catch (_) {}
            final isIn = m.type == 'in';
            NotificationService.notify(isIn ? 'إضافة مخزون' : 'سحب مخزون', '${pname.isNotEmpty ? '$pname — ' : ''}${isIn ? '+' : '-'}${m.quantity.toStringAsFixed(0)}', icon: '📦');
          } catch (_) {}
        }
      });

      // ===== الموظفون =====
      final staff = realm.all<Staff>();
      staff.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final s = staff[i];
            NotificationService.notify('موظف جديد', '${s.name} (${s.role})', icon: '👥');
          } catch (_) {}
        }
      });

      final pays = realm.all<StaffPayment>();
      pays.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final p = pays[i];
            String name = '';
            try { name = (realm.query<Staff>('id == \$0', [p.staffId]).first?.name) ?? ''; } catch (_) {}
            NotificationService.notify('صرف راتب', '${name.isNotEmpty ? '$name — ' : ''}${p.amount.toStringAsFixed(2)} ${Cur.v}', icon: '💰');
          } catch (_) {}
        }
      });

      final att = realm.all<StaffAttendance>();
      att.changes.listen((ch) {
        for (final i in ch.inserted) {
          try {
            final a = att[i];
            String name = '';
            try { name = (realm.query<Staff>('id == \$0', [a.staffId]).first?.name) ?? ''; } catch (_) {}
            final label = a.status == 'present' ? 'حضور موظف' : (a.status == 'absent' ? 'غياب موظف' : 'إجازة موظف');
            NotificationService.notify(label, name, icon: a.status == 'present' ? '✅' : (a.status == 'absent' ? '🚨' : '🏖️'));
          } catch (_) {}
        }
      });

      debugPrint('👁️ WatcherService started — monitoring ALL operations');
    } catch (e) {
      debugPrint('⚠️ WatcherService failed: $e');
    }
  }
}
