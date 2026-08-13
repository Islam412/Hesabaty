import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/app.dart';
import '../../app/theme.dart';
import '../../core/services/settings_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    void setLocale(String code) {
      ref.read(localeProvider.notifier).state = Locale(code);
      SettingsService.saveLocale(code);
    }

    void setTheme(ThemeMode mode, String code) {
      ref.read(themeModeProvider.notifier).state = mode;
      SettingsService.saveThemeMode(code);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.language, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('العربية'),
                  value: 'ar',
                  groupValue: locale.languageCode,
                  onChanged: (v) => setLocale(v ?? 'ar'),
                ),
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: locale.languageCode,
                  onChanged: (v) => setLocale(v ?? 'en'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.appearance, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.light),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) => setTheme(ThemeMode.light, 'light'),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.dark),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) => setTheme(ThemeMode.dark, 'dark'),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.system),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) => setTheme(ThemeMode.system, 'system'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
