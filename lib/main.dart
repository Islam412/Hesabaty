import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'app/app.dart';
import 'core/services/settings_service.dart';
import 'core/services/backup_service.dart';

ThemeMode _parseTheme(String? code) {
  switch (code) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeCode = await SettingsService.getLocale();
  final themeCode = await SettingsService.getThemeMode();
  BackupService.autoBackup();
  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => Locale(localeCode ?? 'ar')),
        themeModeProvider.overrideWith((ref) => _parseTheme(themeCode)),
      ],
      child: const DebtCashApp(),
    ),
  );
}
