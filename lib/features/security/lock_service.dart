import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LockType { none, biometric, pin, password, pattern }

class LockService {
  static const _kType = 'lock_type';
  static const _kHash = 'lock_hash';
  static const _kBiometric = 'lock_biometric';
  static final LocalAuthentication _auth = LocalAuthentication();

  static String _hash(String v) => sha256.convert(utf8.encode(v)).toString();

  static Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> authenticateBiometric() async {
    try {
      return await _auth.authenticate(localizedReason: 'افتح التطبيق باستخدام بصمتك');
    } catch (_) {
      return false;
    }
  }

  static Future<LockType> getType() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kType) ?? 'none';
    return LockType.values.firstWhere((e) => e.name == s, orElse: () => LockType.none);
  }

  static Future<bool> isLocked() async {
    final t = await getType();
    return t != LockType.none;
  }

  static Future<String?> getHash() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kHash);
  }

  static Future<bool> getBiometricEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kBiometric) ?? false;
  }

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kType, LockType.pin.name);
    await p.setString(_kHash, _hash(pin));
  }

  static Future<void> setPassword(String pw) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kType, LockType.password.name);
    await p.setString(_kHash, _hash(pw));
  }

  static Future<void> setPattern(List<int> points) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kType, LockType.pattern.name);
    await p.setString(_kHash, _hash(points.join(',')));
  }

  static Future<void> enableBiometric(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kBiometric, v);
  }

  static Future<void> disable() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kType, LockType.none.name);
    await p.remove(_kHash);
    await p.setBool(_kBiometric, false);
  }

  static Future<bool> verifyPin(String pin) async => _hash(pin) == await getHash();
  static Future<bool> verifyPassword(String pw) async => _hash(pw) == await getHash();
  static Future<bool> verifyPattern(List<int> points) async => _hash(points.join(',')) == await getHash();
}
