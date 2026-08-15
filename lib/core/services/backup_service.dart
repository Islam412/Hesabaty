import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'account_service.dart';
import 'storage_service.dart';
import 'package:realm/realm.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class BackupService {
  static Future<Directory> _backupDir() async {
    final basePath = await StorageService.basePath();
    final phone = await AccountService.sessionPhone() ?? 'default';
    final dir = Directory('${basePath}/HesabatyBackups/$phone');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<List<File>> listBackups() async {
    final dir = await _backupDir();
    if (!await dir.exists()) return [];
    final files = await dir.list().where((e) => e is File && e.path.endsWith('.json')).cast<File>().toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }

  static Future<File> createBackup({bool auto = false}) async {
    final realm = await RealmService.realm;
    final data = {
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'auto': auto,
      'contacts': realm.all<Contact>().map((c) => {
        'id': c.id.toString(), 'businessId': c.businessId, 'name': c.name,
        'phone': c.phone, 'address': c.address, 'type': c.type,
        'tags': c.tags.toList(), 'createdAt': c.createdAt.toIso8601String(),
        'isDeleted': c.isDeleted,
      }).toList(),
      'cash': realm.all<CashTransaction>().map((t) => {
        'id': t.id.toString(), 'businessId': t.businessId,
        'amount': t.amount, 'type': t.type, 'note': t.note,
        'date': t.date.toIso8601String(), 'balanceAfter': t.balanceAfter, 'status': t.status,
      }).toList(),
      'debt': realm.all<DebtTransaction>().map((t) => {
        'id': t.id.toString(), 'contactId': t.contactId,
        'amount': t.amount, 'type': t.type, 'note': t.note,
        'date': t.date.toIso8601String(), 'balanceAfter': t.balanceAfter, 'status': t.status,
      }).toList(),
    };

    final dir = await _backupDir();
    final ts = DateTime.now();
    final name = '${auto ? 'auto' : 'manual'}_${ts.year}${_p(ts.month)}${_p(ts.day)}_${_p(ts.hour)}${_p(ts.minute)}${_p(ts.second)}.json';
    final f = File('${dir.path}/$name');
    await f.writeAsString(jsonEncode(data));
    return f;
  }

  static String _p(int n) => n.toString().padLeft(2, '0');

  static Future<void> restore(File file) async {
    final content = await file.readAsString();
    final data = jsonDecode(content);
    final realm = await RealmService.realm;
    realm.write(() {
      realm.deleteAll<Contact>();
      realm.deleteAll<CashTransaction>();
      realm.deleteAll<DebtTransaction>();
      for (final m in (data['contacts'] as List)) {
        realm.add(Contact(ObjectId(), m['businessId'], m['name'], m['type'], DateTime.parse(m['createdAt']),
          phone: m['phone'], address: m['address'], tags: List<String>.from(m['tags'] ?? []), isDeleted: m['isDeleted'] ?? false));
      }
      for (final m in (data['cash'] as List)) {
        realm.add(CashTransaction(ObjectId(), m['businessId'], (m['amount'] as num).toDouble(), m['type'],
          DateTime.parse(m['date']), (m['balanceAfter'] as num).toDouble(), m['status'],
          note: m['note']));
      }
      for (final m in (data['debt'] as List)) {
        realm.add(DebtTransaction(ObjectId(), m['contactId'], (m['amount'] as num).toDouble(), m['type'],
          DateTime.parse(m['date']), (m['balanceAfter'] as num).toDouble(), m['status'],
          note: m['note']));
      }
    });
  }

  static Future<void> cleanupOldBackups({int keep = 5}) async {
    final files = await listBackups();
    if (files.length <= keep) return;
    for (var i = keep; i < files.length; i++) {
      try { await files[i].delete(); } catch (_) {}
    }
  }

  static Future<String> backupPath() async => (await _backupDir()).path;
}
