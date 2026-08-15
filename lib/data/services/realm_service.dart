import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import '../models/app_models.dart';
import '../../core/services/account_service.dart';
import '../../core/services/storage_service.dart';

class RealmService {
  static Realm? _realm;

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

  static void reset() {
    try {
      _realm?.close();
    } catch (_) {}
    _realm = null;
  }

  static Future<String> _path() async {
    final base = await StorageService.basePath();
    final phone = await AccountService.sessionPhone();
    if (phone == null || phone.isEmpty) return '${base}/hesabaty.realm';
    final per = File('${base}/hesabaty_$phone.realm');
    // أول حساب بس بينقل البيانات القديمة بتاعته لملفه الخاص مرة واحدة
    final first = await AccountService.firstPhone();
    if (first == phone && !per.existsSync()) {
      final legacy = File('${base}/hesabaty.realm');
      if (legacy.existsSync()) {
        try {
          legacy.copySync(per.path);
        } catch (_) {}
      }
    }
    return per.path;
  }

  static Future<Realm> get realm async {
    if (_realm != null && !_realm!.isClosed) return _realm!;
    final path = await _path();
    try {
      _realm = Realm(Configuration.local(_schemas, path: path));
    } catch (_) {
      for (final suffix in ['', '.lock', '.note']) {
        try {
          final f = File(path + suffix);
          if (f.existsSync()) f.deleteSync();
        } catch (_) {}
      }
      try {
        final m = Directory('$path.management');
        if (m.existsSync()) m.deleteSync(recursive: true);
      } catch (_) {}
      _realm = Realm(Configuration.local(_schemas, path: path));
    }
    return _realm!;
  }
}
