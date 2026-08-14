import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import 'backup_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _row(IconData icon, String title, Color color, {VoidCallback? onTap, Widget? extra}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            if (extra != null) ...[extra, const SizedBox(width: 8)],
            Icon(Icons.chevron_left, color: color, size: 26),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings, color: Colors.white, size: 40),
                SizedBox(width: 12),
                Text('الإعدادات', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== النسخ الاحتياطي التلقائي =====
          _row(Icons.cloud_upload_outlined, l10n.backupSettings, AppTheme.primaryBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSettingsScreen()))),
          const Divider(),

          // ===== باقي الإعدادات =====
          _row(Icons.language, l10n.language, const Color(0xFF7C4DFF)),
          const Divider(),
          _row(Icons.dark_mode_outlined, l10n.darkMode, const Color(0xFF607D8B)),
          const Divider(),
          _row(Icons.currency_exchange, l10n.currency, const Color(0xFFE5A83B)),
          const Divider(),
          _row(Icons.notifications_outlined, l10n.notifications, const Color(0xFFFF7043)),
          const Divider(),
          _row(Icons.lock_outline, l10n.appLock, const Color(0xFFE91E63)),
          const Divider(),
          _row(Icons.storage_outlined, l10n.storage, const Color(0xFF00BCD4)),
          const Divider(),
          _row(Icons.info_outline, l10n.aboutApp, AppTheme.incomeGreen),
        ],
      ),
    );
  }
}
