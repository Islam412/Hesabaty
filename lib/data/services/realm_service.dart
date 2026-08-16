import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import '../models/app_models.dart';
import '../../core/services/account_service.dart';
import '../../core/services/storage_service.dart';

class RealmService {
  static Realm? _realm;
  static String? _openPath;

  static List<SchemaObject> get _schemas => [
        Business.schema,
        Contact.schema,
        CashTransaction.schema,
        DebtTransaction.schema,
        Reminder.schema,
        LinkedCard.schema,
        WalletTransaction.schema,
        Product.schema,
        StockMovement.schema,
        Staff.schema,
        StaffPayment.schema,
        StaffAttendance.schema,
      ];

  static Future<void> reset() async {
    try {
      if (_realm != null && !_realm!.isClosed) _realm!.close();
    } catch (e) {
      debugPrint('⚠️ Realm close error: $e');
    }
    _realm = null;
    _openPath = null;
    debugPrint('🔄 RealmService reset');
  }

  static Future<String> _path() async {
    final base = await StorageService.basePath();
    final phone = await AccountService.sessionPhone();
    if (phone == null || phone.isEmpty) return '$base/hesabaty.realm';
    final per = File('$base/hesabaty_$phone.realm');
    // أول حساب فقط: ينقل بياناته من الملفات القديمة مرة واحدة
    if (!per.existsSync()) {
      final first = await AccountService.firstPhone();
      if (first == phone) {
        for (final oldName in ['hesabaty_\$phone.realm', 'hesabaty.realm']) {
          final old = File('$base/$oldName');
          if (old.existsSync()) {
            try {
              old.copySync(per.path);
              debugPrint('📦 Migrated $oldName → ${per.path}');
            } catch (_) {}
            break;
          }
        }
      }
    }
    return per.path;
  }

  static Future<Realm> get realm async {
    final path = await _path();
    // لو مفتوح على ملف تاني → اغلقه
    if (_realm != null && _openPath != path) {
      debugPrint('🔀 Path changed: $_openPath → $path');
      await reset();
    }
    if (_realm != null && !_realm!.isClosed) return _realm!;

    try {
      _realm = Realm(Configuration.local(_schemas, path: path));
      _openPath = path;
      debugPrint('✅ Realm opened: $path');
    } catch (e) {
      // ❗ مستحيل نحذف البيانات — بنحفظ الملف القديم كـ .bak ونفتح جديد
      debugPrint('❌ Realm open FAILED: $e');
      debugPrint('🛡️ Preserving old data as .bak ...');
      for (final suffix in ['', '.lock', '.note']) {
        try {
          final f = File(path + suffix);
          if (f.existsSync()) f.renameSync('$path$suffix.corrupt.bak');
        } catch (_) {}
      }
      try {
        final m = Directory('$path.management');
        if (m.existsSync()) m.renameSync('$path.management.corrupt.bak');
      } catch (_) {}
      _realm = Realm(Configuration.local(_schemas, path: path));
      _openPath = path;
      debugPrint('✅ Realm recreated (old data preserved in .bak): $path');
    }
    return _realm!;
  }
}
