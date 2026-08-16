import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_service.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class BackupService {
  static const _sharedKeys = [
    'profile_name', 'profile_owner', 'profile_phone', 'profile_address', 'profile_currency',
    'bc_name', 'bc_phone', 'bc_address', 'bc_logo', 'bc_color',
    'pay_vodafone', 'pay_instapay', 'pay_bank', 'pay_methods',
    'ab_enabled', 'ab_interval', 'ab_last',
    'locale_code', 'theme_dark',
  ];

  static Future<String> backupPath() async => (await backupDir()).path;

  static Future<Directory> backupDir() async {
    final base = await StorageService.basePath();
    final phone = await AccountService.sessionPhone() ?? 'default';
    final d = Directory('$base/HesabatyBackups/$phone');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  static Future<File> createBackup({bool auto = false}) async {
    final phone = await AccountService.sessionPhone() ?? 'default';
    final dir = await backupDir();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final f = File('${dir.path}/${auto ? 'auto' : 'manual'}_$ts.json');
    debugPrint('💾 Creating backup for $phone');

    final realm = await RealmService.realm;
    final data = <String, dynamic>{
      'version': 3,
      'phone': phone,
      'createdAt': DateTime.now().toIso8601String(),
      'auto': auto,
      'cash': realm.all<CashTransaction>().map(_cashToMap).toList(),
      'debt': realm.all<DebtTransaction>().map(_debtToMap).toList(),
      'contacts': realm.all<Contact>().map(_contactToMap).toList(),
      'wallet': realm.all<WalletTransaction>().map(_walletToMap).toList(),
      'cards': realm.all<LinkedCard>().map(_cardToMap).toList(),
      'products': realm.all<Product>().map(_productToMap).toList(),
      'stock_moves': realm.all<StockMovement>().map(_stockMoveToMap).toList(),
      'staff': realm.all<Staff>().map(_staffToMap).toList(),
      'staff_payments': realm.all<StaffPayment>().map(_staffPaymentToMap).toList(),
      'staff_attendance': realm.all<StaffAttendance>().map(_staffAttendanceToMap).toList(),
      'reminders': realm.all<Reminder>().map(_reminderToMap).toList(),
      'business': realm.all<Business>().map(_businessToMap).toList(),
    };

    final p = await AccPrefs.scoped();
    final prefs = <String, dynamic>{};
    for (final k in _sharedKeys) {
      final v = p.get(k);
      if (v != null) prefs[k] = v.toString();
    }
    for (final k in p.getKeys()) {
      if (k.startsWith('acc_${phone}_')) prefs[k] = p.get(k).toString();
    }
    data['prefs'] = prefs;

    await f.writeAsString(jsonEncode(data));
    final sizeKB = (await f.length() / 1024).toStringAsFixed(1);
    debugPrint('✅ Backup saved: $sizeKB KB');
    await NotificationService.notify(auto ? 'نسخة احتياطية تلقائية' : 'نسخة احتياطية', 'حساب $phone — $sizeKB KB', icon: '💾');
    return f;
  }

  // ================= EXPORT =================
  static Map<String, dynamic> _cashToMap(CashTransaction t) => {
        'id': t.id.toString(), 'businessId': t.businessId, 'amount': t.amount, 'type': t.type,
        'date': t.date.toIso8601String(), 'balanceAfter': t.balanceAfter, 'status': t.status,
        'note': t.note, 'imagePath': t.imagePath,
      };
  static Map<String, dynamic> _debtToMap(DebtTransaction t) => {
        'id': t.id.toString(), 'contactId': t.contactId, 'amount': t.amount, 'type': t.type,
        'date': t.date.toIso8601String(), 'balanceAfter': t.balanceAfter, 'status': t.status,
        'note': t.note, 'imagePath': t.imagePath,
      };
  static Map<String, dynamic> _contactToMap(Contact c) => {
        'id': c.id.toString(), 'businessId': c.businessId, 'name': c.name, 'type': c.type,
        'createdAt': c.createdAt.toIso8601String(), 'phone': c.phone, 'address': c.address,
        'tags': c.tags.toList(), 'isDeleted': c.isDeleted,
      };
  static Map<String, dynamic> _walletToMap(WalletTransaction t) => {
        'id': t.id, 'businessId': t.businessId, 'type': t.type, 'amount': t.amount,
        'provider': t.provider, 'destination': t.destination, 'destinationType': t.destinationType,
        'status': t.status, 'date': t.date.toIso8601String(), 'balanceAfter': t.balanceAfter,
        'reference': t.reference, 'note': t.note,
      };
  static Map<String, dynamic> _cardToMap(LinkedCard c) => {
        'id': c.id, 'businessId': c.businessId, 'last4': c.last4, 'brand': c.brand,
        'expiry': c.expiry, 'cardholderName': c.cardholderName, 'token': c.token,
        'isDefault': c.isDefault, 'addedAt': c.addedAt.toIso8601String(), 'bank': c.bank, 'balance': c.balance,
      };
  static Map<String, dynamic> _productToMap(Product p) => {
        'id': p.id.toString(), 'businessId': p.businessId, 'name': p.name, 'sku': p.sku,
        'category': p.category, 'price': p.price, 'cost': p.cost, 'stock': p.stock,
        'minStock': p.minStock, 'createdAt': p.createdAt.toIso8601String(), 'isDeleted': p.isDeleted,
        'unit': p.unit, 'notes': p.notes,
      };
  static Map<String, dynamic> _stockMoveToMap(StockMovement m) => {
        'id': m.id.toString(), 'productId': m.productId, 'type': m.type, 'quantity': m.quantity,
        'unitPrice': m.unitPrice, 'date': m.date.toIso8601String(), 'status': m.status, 'note': m.note,
      };
  static Map<String, dynamic> _staffToMap(Staff s) => {
        'id': s.id.toString(), 'businessId': s.businessId, 'name': s.name, 'role': s.role,
        'salary': s.salary, 'salaryType': s.salaryType, 'joinDate': s.joinDate.toIso8601String(),
        'isActive': s.isActive, 'createdAt': s.createdAt.toIso8601String(),
        'phone': s.phone, 'address': s.address, 'notes': s.notes,
      };
  static Map<String, dynamic> _staffPaymentToMap(StaffPayment p) => {
        'id': p.id.toString(), 'staffId': p.staffId, 'amount': p.amount, 'type': p.type,
        'date': p.date.toIso8601String(), 'status': p.status, 'note': p.note,
      };
  static Map<String, dynamic> _staffAttendanceToMap(StaffAttendance a) => {
        'id': a.id.toString(), 'staffId': a.staffId, 'date': a.date.toIso8601String(),
        'status': a.status, 'note': a.note,
      };
  static Map<String, dynamic> _reminderToMap(Reminder r) => {
        'id': r.id.toString(), 'dueDate': r.dueDate.toIso8601String(), 'message': r.message,
        'contactId': r.contactId, 'isDone': r.isDone,
      };
  static Map<String, dynamic> _businessToMap(Business b) => {
        'id': b.id.toString(), 'name': b.name, 'currency': b.currency,
        'createdAt': b.createdAt.toIso8601String(), 'phone': b.phone, 'address': b.address,
      };

  // ================= LIST / DELETE / CLEANUP =================
  static Future<List<File>> listBackups() async {
    final dir = await backupDir();
    if (!await dir.exists()) return [];
    final files = await dir.list().where((e) => e is File && e.path.endsWith('.json')).toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files.cast<File>();
  }

  static Future<void> deleteBackup(File f) async {
    if (await f.exists()) await f.delete();
  }

  static Future<void> cleanupOldBackups({int keep = 5}) async {
    final files = await listBackups();
    for (final f in files.skip(keep)) {
      await deleteBackup(f);
    }
  }

  static Future<void> restore(File f) => restoreBackup(f);

  // ================= RESTORE =================
  static Future<void> restoreBackup(File f) async {
    if (!await f.exists()) return;
    final phone = await AccountService.sessionPhone() ?? 'default';
    final data = jsonDecode(await f.readAsString()) as Map<String, dynamic>;

    final realm = await RealmService.realm;
    realm.write(() {
      realm.deleteAll<CashTransaction>();
      realm.deleteAll<DebtTransaction>();
      realm.deleteAll<Contact>();
      realm.deleteAll<WalletTransaction>();
      realm.deleteAll<LinkedCard>();
      realm.deleteAll<Product>();
      realm.deleteAll<StockMovement>();
      realm.deleteAll<Staff>();
      realm.deleteAll<StaffPayment>();
      realm.deleteAll<StaffAttendance>();
      realm.deleteAll<Reminder>();
      realm.deleteAll<Business>();
    });

    realm.write(() {
      for (final m in (data['contacts'] as List?) ?? []) _rContact(realm, m);
      for (final m in (data['cash'] as List?) ?? []) _rCash(realm, m);
      for (final m in (data['debt'] as List?) ?? []) _rDebt(realm, m);
      for (final m in (data['wallet'] as List?) ?? []) _rWallet(realm, m);
      for (final m in (data['cards'] as List?) ?? []) _rCard(realm, m);
      for (final m in (data['products'] as List?) ?? []) _rProduct(realm, m);
      for (final m in (data['stock_moves'] as List?) ?? []) _rStockMove(realm, m);
      for (final m in (data['staff'] as List?) ?? []) _rStaff(realm, m);
      for (final m in (data['staff_payments'] as List?) ?? []) _rStaffPayment(realm, m);
      for (final m in (data['staff_attendance'] as List?) ?? []) _rStaffAttendance(realm, m);
      for (final m in (data['reminders'] as List?) ?? []) _rReminder(realm, m);
      for (final m in (data['business'] as List?) ?? []) _rBusiness(realm, m);
    });

    final prefs = (data['prefs'] as Map?) ?? {};
    final p = await AccPrefs.scoped();
    for (final e in prefs.entries) {
      try {
        final v = e.value.toString();
        if (v == 'true' || v == 'false') await p.setBool(e.key, v == 'true');
        else if (int.tryParse(v) != null) await p.setInt(e.key, int.parse(v));
        else await p.setString(e.key, v);
      } catch (_) {}
    }

    await NotificationService.notify('استعادة النسخة', 'تم استعادة حساب $phone بنجاح ♻️', icon: '♻️');
  }

  static ObjectId _oid(dynamic v) => ObjectId.fromHexString(v.toString());
  static double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;
  static DateTime _dt(dynamic v) => DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();

  static void _rCash(Realm r, Map m) {
    try {
      r.add(CashTransaction(_oid(m['id']), m['businessId'] ?? '', _d(m['amount']), m['type'] ?? 'in', _dt(m['date']), _d(m['balanceAfter']), m['status'] ?? 'active', note: m['note'], imagePath: m['imagePath']));
    } catch (_) {}
  }

  static void _rDebt(Realm r, Map m) {
    try {
      r.add(DebtTransaction(_oid(m['id']), m['contactId'] ?? '', _d(m['amount']), m['type'] ?? 'given', _dt(m['date']), _d(m['balanceAfter']), m['status'] ?? 'active', note: m['note'], imagePath: m['imagePath']));
    } catch (_) {}
  }

  static void _rContact(Realm r, Map m) {
    try {
      r.add(Contact(_oid(m['id']), m['businessId'] ?? '', m['name'] ?? '', m['type'] ?? 'customer', _dt(m['createdAt']), phone: m['phone'], address: m['address'], tags: (m['tags'] as List?)?.map((e) => e.toString()).toList() ?? [], isDeleted: m['isDeleted'] ?? false));
    } catch (_) {}
  }

  static void _rWallet(Realm r, Map m) {
    try {
      r.add(WalletTransaction(m['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), m['businessId'] ?? '', m['type'] ?? 'send', _d(m['amount']), m['provider'] ?? '', m['destination'] ?? '', m['destinationType'] ?? '', m['status'] ?? 'success', _dt(m['date']), _d(m['balanceAfter']), reference: m['reference'], note: m['note']));
    } catch (_) {}
  }

  static void _rCard(Realm r, Map m) {
    try {
      r.add(LinkedCard(m['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(), m['businessId'] ?? '', m['last4'] ?? '', m['brand'] ?? '', m['expiry'] ?? '', m['cardholderName'] ?? '', m['token'] ?? '', m['isDefault'] ?? false, _dt(m['addedAt']), bank: m['bank'], balance: (m['balance'] as num?)?.toDouble()));
    } catch (_) {}
  }

  static void _rProduct(Realm r, Map m) {
    try {
      r.add(Product(_oid(m['id']), m['businessId'] ?? '', m['name'] ?? '', m['sku'] ?? '', m['category'] ?? '', _d(m['price']), _d(m['cost']), _d(m['stock']), _d(m['minStock']), _dt(m['createdAt']), m['isDeleted'] ?? false, unit: m['unit'], notes: m['notes']));
    } catch (_) {}
  }

  static void _rStockMove(Realm r, Map m) {
    try {
      r.add(StockMovement(_oid(m['id']), m['productId'] ?? '', m['type'] ?? 'in', _d(m['quantity']), _d(m['unitPrice']), _dt(m['date']), m['status'] ?? 'active', note: m['note']));
    } catch (_) {}
  }

  static void _rStaff(Realm r, Map m) {
    try {
      r.add(Staff(_oid(m['id']), m['businessId'] ?? '', m['name'] ?? '', m['role'] ?? '', _d(m['salary']), m['salaryType'] ?? 'monthly', _dt(m['joinDate']), m['isActive'] ?? true, _dt(m['createdAt']), phone: m['phone'], address: m['address'], notes: m['notes']));
    } catch (_) {}
  }

  static void _rStaffPayment(Realm r, Map m) {
    try {
      r.add(StaffPayment(_oid(m['id']), m['staffId'] ?? '', _d(m['amount']), m['type'] ?? 'salary', _dt(m['date']), m['status'] ?? 'active', note: m['note']));
    } catch (_) {}
  }

  static void _rStaffAttendance(Realm r, Map m) {
    try {
      r.add(StaffAttendance(_oid(m['id']), m['staffId'] ?? '', _dt(m['date']), m['status'] ?? 'present', note: m['note']));
    } catch (_) {}
  }

  static void _rReminder(Realm r, Map m) {
    try {
      r.add(Reminder(_oid(m['id']), _dt(m['dueDate']), m['message'] ?? '', contactId: m['contactId'], isDone: m['isDone'] ?? false));
    } catch (_) {}
  }

  static void _rBusiness(Realm r, Map m) {
    try {
      r.add(Business(_oid(m['id']), m['name'] ?? '', m['currency'] ?? 'ج.م', _dt(m['createdAt']), phone: m['phone'], address: m['address']));
    } catch (_) {}
  }
}
