import 'dart:convert';
import '../../app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_session.dart';

class AccountService {
  static const String _kAccounts = 'accounts_map';
  static const String _kFirst = 'first_phone';
  static const String _kLoggedIn = 'logged_in';
  static const String _kSession = 'session_phone';

  static Future<Map<String, Map<String, dynamic>>> _all() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kAccounts) ?? '{}';
    final m = jsonDecode(raw) as Map<String, dynamic>;
    return m.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  static Future<void> _saveAll(Map<String, Map<String, dynamic>> all) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAccounts, jsonEncode(all));
  }

  static Future<bool> exists(String phone) async => (await _all()).containsKey(phone);

  static Future<Map<String, dynamic>?> get(String phone) async => (await _all())[phone];

  static Future<String?> firstPhone() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kFirst);
  }

  static Future<void> register(String phone, {required String name, String owner = '', String address = ''}) async {
    final all = await _all();
    all[phone] = {
      'name': name,
      'owner': owner,
      'address': address,
      'currency': Cur.v,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _saveAll(all);
    final p = await SharedPreferences.getInstance();
    if (p.getString(_kFirst) == null) await p.setString(_kFirst, phone);
    // 🎯 مهم جدًا: تسجيل الدخول تلقائيًا بعد التسجيل عشان العدّاد وقاعدة البيانات يتحولوا فورًا
    await login(phone);
  }

  static Future<void> update(String phone, Map<String, dynamic> data) async {
    final all = await _all();
    final cur = all[phone] ?? {};
    cur.addAll(data);
    all[phone] = cur;
    await _saveAll(all);
  }

  static Future<void> login(String phone) async {
    // 🎯 اغلق Realm الحالي قبل تغيير الحساب عشان يفتح الملف الجديد
    try {
      // استدعاء RealmService.reset بدون circular import
      await _onAccountChange?.call();
    } catch (_) {}
    final p = await SharedPreferences.getInstance();
    final acc = (await _all())[phone];
    await p.setBool(_kLoggedIn, true);
    await p.setString(_kSession, phone);
    await p.setString('profile_phone', phone);
    if (acc != null) {
      await p.setString('profile_name', (acc['name'] ?? 'حساباتي').toString());
      await p.setString('profile_owner', (acc['owner'] ?? '').toString());
      await p.setString('profile_address', (acc['address'] ?? '').toString());
      await p.setString('profile_currency', (acc['currency'] ?? Cur.v).toString());
    }
    final sp = await AccPrefs.scoped();
    await sp.setString('profile_phone', phone);
    await sp.setString('profile_name', (acc?['name'] ?? 'حساباتي').toString());
    await sp.setString('profile_owner', (acc?['owner'] ?? '').toString());
    await sp.setString('profile_address', (acc?['address'] ?? '').toString());
    await sp.setString('profile_currency', (acc?['currency'] ?? Cur.v).toString());
    await AccountSession.onAccountChanged(phone);
  }

  static Future<void> logout() async {
    try { await _onAccountChange?.call(); } catch (_) {}
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLoggedIn, false);
    await p.remove(_kSession);
    await AccountSession.onAccountChanged(null);
  }

  static Future<String?> sessionPhone() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kSession);
  }

  /// callback يُنفذ عند تغيير الحساب (يُضبط من main.dart)
  static Future<void> Function()? _onAccountChange;
  static void onAccountChange(Future<void> Function() cb) => _onAccountChange = cb;
}

class AccPrefs {
  static Future<_ScopedPrefs> scoped() async {
    final p = await SharedPreferences.getInstance();
    final phone = p.getString('session_phone') ?? 'global';
    return _ScopedPrefs(p, 'acc_\${phone}_');
  }
}

class _ScopedPrefs {
  final SharedPreferences _p;
  final String _pre;
  _ScopedPrefs(this._p, this._pre);
  String? getString(String k) => _p.getString(_pre + k);
  Future<bool> setString(String k, String v) => _p.setString(_pre + k, v);
  bool? getBool(String k) => _p.getBool(_pre + k);
  Future<bool> setBool(String k, bool v) => _p.setBool(_pre + k, v);
  int? getInt(String k) => _p.getInt(_pre + k);
  Future<bool> setInt(String k, int v) => _p.setInt(_pre + k, v);
  Object? get(String k) => _p.get(_pre + k);
  Set<String> getKeys() => _p.getKeys().where((k) => k.startsWith(_pre)).map((k) => k.substring(_pre.length)).toSet();
  Future<bool> remove(String k) => _p.remove(_pre + k);
  double? getDouble(String k) => _p.getDouble(_pre + k);
  Future<bool> setDouble(String k, double v) => _p.setDouble(_pre + k, v);
}
