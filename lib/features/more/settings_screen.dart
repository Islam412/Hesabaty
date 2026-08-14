import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app.dart';
import '../../app/theme.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/settings_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoBackup = true;
  String _lastBackup = '';

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  Future<void> _loadBackupInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('auto_backup_enabled') ?? true;
    final last = prefs.getInt('last_auto_backup') ?? 0;
    if (!mounted) return;
    setState(() {
      _autoBackup = enabled;
      _lastBackup = last == 0 ? '' : '${DateTime.fromMillisecondsSinceEpoch(last).toLocal()}';
    });
  }

  Future<void> _exportShare() async {
    final file = await BackupService.exportBackup();
    await Share.shareXFiles([XFile(file.path)], subject: 'Hesabaty Backup');
    _loadBackupInfo();
  }

  Future<void> _restore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final res = await FilePicker.platform.pickFiles();
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;
    try {
      await BackupService.restoreFromFile(path);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                RadioListTile<String>(title: const Text('العربية'), value: 'ar', groupValue: locale.languageCode, onChanged: (v) => setLocale(v ?? 'ar')),
                RadioListTile<String>(title: const Text('English'), value: 'en', groupValue: locale.languageCode, onChanged: (v) => setLocale(v ?? 'en')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.appearance, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(title: Text(l10n.light), value: ThemeMode.light, groupValue: themeMode, onChanged: (v) => setTheme(ThemeMode.light, 'light')),
                RadioListTile<ThemeMode>(title: Text(l10n.dark), value: ThemeMode.dark, groupValue: themeMode, onChanged: (v) => setTheme(ThemeMode.dark, 'dark')),
                RadioListTile<ThemeMode>(title: Text(l10n.system), value: ThemeMode.system, groupValue: themeMode, onChanged: (v) => setTheme(ThemeMode.system, 'system')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.backupSection, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.autoBackupLabel),
                    value: _autoBackup,
                    onChanged: (v) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('auto_backup_enabled', v);
                      setState(() => _autoBackup = v);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('${l10n.lastBackupAt}: ${_lastBackup.isEmpty ? l10n.noBackup : _lastBackup}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(child: FilledButton(onPressed: _exportShare, child: Text(l10n.exportShare))),
                        const SizedBox(width: 8),
                        Expanded(child: OutlinedButton(onPressed: () => _restore(context), child: Text(l10n.restore))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
