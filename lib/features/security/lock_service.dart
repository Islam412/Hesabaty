import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/account_service.dart';

enum LockType { none, biometric, pin, password, pattern }

class LockService {
  static Future<String> _kType() async { final ph = await AccountService.sessionPhone(); return 'lock_type_${ph ?? 'global'}'; }
  static Future<String> _kHash() async { final ph = await AccountService.sessionPhone(); return 'lock_hash_${ph ?? 'global'}'; }
  static Future<String> _kBiometric() async { final ph = await AccountService.sessionPhone(); return 'lock_biometric_${ph ?? 'global'}'; }
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
    final s = p.getString(await _kType()) ?? 'none';
    return LockType.values.firstWhere((e) => e.name == s, orElse: () => LockType.none);
  }

  static Future<bool> isLocked() async {
    final t = await getType();
    return t != LockType.none;
  }

  static Future<String?> getHash() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(await _kHash());
  }

  static Future<bool> getBiometricEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(await _kBiometric()) ?? false;
  }

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(await _kType(), LockType.pin.name);
    await p.setString(await _kHash(), _hash(pin));
  }

  static Future<void> setPassword(String pw) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(await _kType(), LockType.password.name);
    await p.setString(await _kHash(), _hash(pw));
  }

  static Future<void> setPattern(List<int> points) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(await _kType(), LockType.pattern.name);
    await p.setString(await _kHash(), _hash(points.join(',')));
  }

  static Future<void> enableBiometric(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(await _kBiometric(), v);
  }

  static Future<void> setBiometric() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(await _kType(), LockType.biometric.name);
    await p.remove(await _kHash());
  }

  static Future<void> disable() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(await _kType(), LockType.none.name);
    await p.remove(await _kHash());
    await p.setBool(await _kBiometric(), false);
  }

  static Future<bool> verifyPin(String pin) async => _hash(pin) == await getHash();
  static Future<bool> verifyPassword(String pw) async => _hash(pw) == await getHash();
  static Future<bool> verifyPattern(List<int> points) async => _hash(points.join(',')) == await getHash();
}
