import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _localeKey = 'locale';
  static const _themeKey = 'themeMode';
  static const _onboardKey = 'onboarded';
  static const _registeredKey = 'registered';
  static const _phoneKey = 'user_phone';

  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }

  static Future<void> saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardKey) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardKey, true);
  }

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registeredKey) ?? false;
  }

  static Future<void> setRegistered(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registeredKey, true);
    await prefs.setString(_phoneKey, phone);
  }
}
