import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class BackupService {
  static Future<String> _backupDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final backups = Directory('${dir.path}/backups');
    if (!await backups.exists()) await backups.create(recursive: true);
    return backups.path;
  }

  static Future<Map<String, dynamic>> _collect() async {
    final realm = await RealmService.realm;
    return {
      'version': 1,
      'date': DateTime.now().toIso8601String(),
      'contacts': realm.all<Contact>().map((c) => {
            'id': c.id.toString(),
            'businessId': c.businessId,
            'name': c.name,
            'phone': c.phone,
            'address': c.address,
            'type': c.type,
            'tags': c.tags.toList(),
            'createdAt': c.createdAt.toIso8601String(),
            'isDeleted': c.isDeleted,
          }).toList(),
      'cash': realm.all<CashTransaction>().map((t) => {
            'id': t.id.toString(),
            'businessId': t.businessId,
            'amount': t.amount,
            'type': t.type,
            'note': t.note,
            'date': t.date.toIso8601String(),
            'balanceAfter': t.balanceAfter,
            'status': t.status,
          }).toList(),
      'debt': realm.all<DebtTransaction>().map((t) => {
            'id': t.id.toString(),
            'contactId': t.contactId,
            'amount': t.amount,
            'type': t.type,
            'note': t.note,
            'date': t.date.toIso8601String(),
            'balanceAfter': t.balanceAfter,
            'status': t.status,
          }).toList(),
    };
  }

  static Future<File> exportBackup() async {
    final data = await _collect();
    final path = await _backupDir();
    final now = DateTime.now();
    final name = 'backup_${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
    final file = File('$path/$name');
    final encoded = jsonEncode(data);
    await file.writeAsString(encoded);
    await File('$path/latest_backup.json').writeAsString(encoded);
    return file;
  }

  static Future<void> autoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('auto_backup_enabled') ?? true;
      if (!enabled) return;
      final last = prefs.getInt('last_auto_backup') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - last < 24 * 60 * 60 * 1000) return;
      await exportBackup();
      await prefs.setInt('last_auto_backup', now);
    } catch (_) {}
  }

  static Future<void> restoreFromFile(String filePath) async {
    final content = await File(filePath).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final realm = await RealmService.realm;
    realm.write(() {
      realm.deleteAll<DebtTransaction>();
      realm.deleteAll<CashTransaction>();
      realm.deleteAll<Contact>();
    });
    realm.write(() {
      for (final c in (data['contacts'] as List? ?? [])) {
        final m = c as Map<String, dynamic>;
        realm.add(Contact(
          ObjectId.fromHexString(m['id'] as String),
          (m['businessId'] as String?) ?? 'business_1',
          m['name'] as String,
          m['type'] as String,
          DateTime.parse(m['createdAt'] as String),
          phone: m['phone'] as String?,
          address: m['address'] as String?,
          tags: (m['tags'] as List? ?? []).cast<String>(),
          isDeleted: (m['isDeleted'] as bool?) ?? false,
        ));
      }
      for (final t in (data['cash'] as List? ?? [])) {
        final m = t as Map<String, dynamic>;
        realm.add(CashTransaction(
          ObjectId.fromHexString(m['id'] as String),
          (m['businessId'] as String?) ?? 'business_1',
          (m['amount'] as num).toDouble(),
          m['type'] as String,
          DateTime.parse(m['date'] as String),
          (m['balanceAfter'] as num).toDouble(),
          (m['status'] as String?) ?? 'active',
          note: m['note'] as String?,
        ));
      }
      for (final t in (data['debt'] as List? ?? [])) {
        final m = t as Map<String, dynamic>;
        realm.add(DebtTransaction(
          ObjectId.fromHexString(m['id'] as String),
          m['contactId'] as String,
          (m['amount'] as num).toDouble(),
          m['type'] as String,
          DateTime.parse(m['date'] as String),
          (m['balanceAfter'] as num).toDouble(),
          (m['status'] as String?) ?? 'active',
          note: m['note'] as String?,
        ));
      }
    });
  }
}
