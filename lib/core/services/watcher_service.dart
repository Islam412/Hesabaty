import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'notification_service.dart';

class WatcherService {
  static bool _started = false;

  static String _dt(DateTime d) {
    return DateFormat('yyyy/MM/dd  HH:mm').format(d);
  }

  static Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final realm = await RealmService.realm;

      // ===== دفتر الديون (قبض/دفع) =====
      final debt = realm.all<DebtTransaction>();
      debt.changes.listen((ch) async {
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
          } catch (_) {}
        }
      });

      // ===== دفتر النقدية (دخل/مصروف) =====
      final cash = realm.all<CashTransaction>();
      cash.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final t = cash[i];
            if (t.status == 'deleted') continue;
            final isIn = t.type.contains('in');
            final icon = isIn ? '💵' : '💸';
            final title = isIn ? 'دخل نقدي جديد' : 'مصروف نقدي جديد';
            final body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}\nالنوع: ${isIn ? "دخل" : "مصروف"}\nالتاريخ: ${_dt(t.date)}${(t.note ?? '').isNotEmpty ? '\nملاحظة: ${t.note}' : ''}';
            await NotificationService.notify(title, body, icon: icon);
          } catch (_) {}
        }
      });

      // ===== المحفظة التجارية (شحن/إرسال/دفع فاتورة) =====
      final wtx = realm.all<WalletTransaction>();
      wtx.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final t = wtx[i];
            if (t.status != 'success') continue;
            String title;
            String icon;
            String body;
            if (t.type == 'topup') {
              title = 'تم شحن المحفظة';
              icon = '👛';
              body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}\nالتاريخ: ${_dt(t.date)}${(t.note ?? '').isNotEmpty ? '\nملاحظة: ${t.note}' : ''}';
            } else if (t.type == 'bill') {
              title = 'تم دفع فاتورة';
              icon = '🧾';
              body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}\nالتاريخ: ${_dt(t.date)}${(t.note ?? '').isNotEmpty ? '\nالفاتورة: ${t.note}' : ''}';
            } else {
              title = 'تم تحويل مبلغ';
              icon = '💸';
              body = 'المبلغ: ${t.amount.toStringAsFixed(2)} ${Cur.v}\nالتاريخ: ${_dt(t.date)}${(t.note ?? '').isNotEmpty ? '\nالجهة: ${t.note}' : ''}';
            }
            await NotificationService.notify(title, body, icon: icon);
          } catch (_) {}
        }
      });

      // ===== ربط بطاقة فيزا/ماستركارد =====
      final cards = realm.all<LinkedCard>();
      cards.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final c = cards[i];
            await NotificationService.notify(
              'تم إضافة بطاقة جديدة 💳',
              'البنك: ${c.bank ?? 'غير محدد'}\nالعلامة: ${c.brand}\nالرقم: •••• ${c.last4}\nانتهاء: ${c.expiry}',
              icon: '💳',
            );
          } catch (_) {}
        }
      });

      // ===== المخزون (منتج جديد/حركة مخزون) =====
      final products = realm.all<Product>();
      products.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final p = products[i];
            await NotificationService.notify(
              'منتج جديد في المخزون 📦',
              'الاسم: ${p.name}\nالكود: ${p.sku}\nالفئة: ${p.category}\nالمخزون: ${p.stock.toStringAsFixed(0)} ${p.unit ?? "قطعة"}\nالسعر: ${p.price.toStringAsFixed(2)} ${Cur.v}',
              icon: '📦',
            );
          } catch (_) {}
        }
      });

      final moves = realm.all<StockMovement>();
      moves.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final m = moves[i];
            String pname = 'منتج';
            try {
              final p = realm.query<Product>('id == \$0', [ObjectId.fromHexString(m.productId)]).first;
              pname = p?.name ?? 'منتج';
            } catch (_) {}
            final isIn = m.type == 'in';
            final title = isIn ? 'إضافة إلى مخزون $pname' : 'سحب من مخزون $pname';
            final body = 'الكمية: ${isIn ? "+" : "-"}${m.quantity.toStringAsFixed(0)}\nالتاريخ: ${_dt(m.date)}${(m.note ?? '').isNotEmpty ? '\nملاحظة: ${m.note}' : ''}';
            await NotificationService.notify(title, body, icon: '📦');
          } catch (_) {}
        }
      });

      // ===== الموظفون (موظف جديد/صرف راتب/حضور) =====
      final staff = realm.all<Staff>();
      staff.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final s = staff[i];
            await NotificationService.notify(
              'موظف جديد 👥',
              'الاسم: ${s.name}\nالوظيفة: ${s.role}\nالراتب: ${s.salary.toStringAsFixed(2)} ${Cur.v} (${s.salaryType == "monthly" ? "شهري" : (s.salaryType == "weekly" ? "أسبوعي" : "يومي")})\nتاريخ التعيين: ${_dt(s.joinDate)}',
              icon: '👥',
            );
          } catch (_) {}
        }
      });

      final pays = realm.all<StaffPayment>();
      pays.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final p = pays[i];
            String name = 'موظف';
            try {
              final s = realm.query<Staff>('id == \$0', [ObjectId.fromHexString(p.staffId)]).first;
              name = s?.name ?? 'موظف';
            } catch (_) {}
            await NotificationService.notify(
              'تم صرف راتب لـ $name 💰',
              'المبلغ: ${p.amount.toStringAsFixed(2)} ${Cur.v}\nالتاريخ: ${_dt(p.date)}${(p.note ?? '').isNotEmpty ? '\nملاحظة: ${p.note}' : ''}',
              icon: '💰',
            );
          } catch (_) {}
        }
      });

      final att = realm.all<StaffAttendance>();
      att.changes.listen((ch) async {
        for (final i in ch.inserted) {
          try {
            final a = att[i];
            String name = 'موظف';
            try {
              final s = realm.query<Staff>('id == \$0', [ObjectId.fromHexString(a.staffId)]).first;
              name = s?.name ?? 'موظف';
            } catch (_) {}
            final label = a.status == 'present' ? 'حضور' : (a.status == 'absent' ? 'غياب' : 'إجازة');
            final icon = a.status == 'present' ? '✅' : (a.status == 'absent' ? '🚨' : '🏖️');
            await NotificationService.notify(
              '$label موظف: $name',
              'الحالة: $label\nالتاريخ: ${_dt(a.date)}${(a.note ?? '').isNotEmpty ? '\nملاحظة: ${a.note}' : ''}',
              icon: icon,
            );
          } catch (_) {}
        }
      });

      debugPrint('👁️ WatcherService started — monitoring ALL operations with full details');
    } catch (e) {
      debugPrint('⚠️ WatcherService failed: $e');
    }
  }
}
