import 'package:realm/realm.dart';
import '../models/app_models.dart';
import '../services/realm_service.dart';

class ReminderRepository {
  static Future<List<Reminder>> getAll() async {
    final realm = await RealmService.realm;
    return realm.all<Reminder>().toList();
  }

  static Future<void> add(Reminder r) async {
    final realm = await RealmService.realm;
    realm.write(() => realm.add(r));
  }

  static Future<void> delete(Reminder r) async {
    final realm = await RealmService.realm;
    realm.write(() => realm.delete(r));
  }

  static Future<void> markDone(Reminder r) async {
    final realm = await RealmService.realm;
    realm.write(() => r.isDone = true);
  }
}
