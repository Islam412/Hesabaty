import 'package:realm/realm.dart';
import '../models/app_models.dart';

class RealmService {
  static Realm? _realm;

  static Future<Realm> get realm async {
    if (_realm != null && !_realm!.isClosed) return _realm!;
    
    final config = Configuration.local(
      [
        Business.schema,
        Contact.schema,
        CashTransaction.schema,
        DebtTransaction.schema,
        Reminder.schema,
      ],
      schemaVersion: 1,
    );
    
    _realm = Realm(config);
    return _realm!;
  }
}
