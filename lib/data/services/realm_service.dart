import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import '../models/app_models.dart';

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
      ];

  static Future<String> _realmPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/hesabaty.realm';
  }

  static Future<Realm> get realm async {
    if (_realm != null && !_realm!.isClosed) return _realm!;
    final path = await _realmPath();
    try {
      _realm = Realm(Configuration.local(_schemas, path: path));
    } catch (_) {
      // لو حصلت مشكلة schema: امسح الملفات وابني من جديد
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
