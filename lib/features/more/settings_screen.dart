import 'package:flutter/material.dart';
import '../security/setup_lock_screen.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/account_service.dart';
import 'backup_settings_screen.dart';
import 'about_screen.dart';
import 'storage_settings_screen.dart';
import 'notifications_screen.dart';
import '../../core/services/notification_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart' as sp;

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
          StatefulBuilder(
            builder: (ctx, setState) => FutureBuilder<String>(
              future: LocaleNotifier.getCode(),
              builder: (ctx, snap) {
                final code = snap.data ?? 'ar';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.12), child: const Icon(Icons.language, color: Color(0xFF7C4DFF))),
                    title: Text(l10n.language, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Text(code == 'ar' ? 'العربية' : 'English', style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_left, color: Color(0xFF7C4DFF)),
                    onTap: () async {
                      final sel = await showDialog<String>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: Text(l10n.language),
                          children: [
                            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'ar'), child: const Text('العربية 🇪', style: TextStyle(fontSize: 16))),
                            SimpleDialogOption(onPressed: () => Navigator.pop(ctx, 'en'), child: const Text('English 🇺🇸', style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      );
                      if (sel != null) {
                        await LocaleNotifier.setCode(sel);
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          StatefulBuilder(
            builder: (ctx, setState) => FutureBuilder<bool>(
              future: ThemeNotifier.isDark(),
              builder: (ctx, snap) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: SwitchListTile(
                  secondary: CircleAvatar(backgroundColor: const Color(0xFF607D8B).withOpacity(0.12), child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF607D8B))),
                  title: Text(l10n.darkMode, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  value: snap.data ?? false,
                  onChanged: (v) async {
                    await ThemeNotifier.toggle();
                    setState(() {});
                  },
                ),
              ),
            ),
          ),
          const Divider(),
          StatefulBuilder(
            builder: (ctx, setState) => FutureBuilder<String>(
              future: CurrencyNotifier.getSymbol(),
              builder: (ctx, snap) {
                final sym = snap.data ?? Cur.v;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: const Color(0xFFE5A83B).withOpacity(0.12), child: const Icon(Icons.currency_exchange, color: Color(0xFFE5A83B))),
                    title: Text(l10n.currency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Text(sym, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_left, color: Color(0xFFE5A83B)),
                    onTap: () async {
                      final sel = await showDialog<String>(
                        context: context,
                        builder: (ctx) => SimpleDialog(
                          title: Text(l10n.currency),
                          children: kCurrencies.map((c) => SimpleDialogOption(
                            onPressed: () => Navigator.pop(ctx, c['symbol']),
                            child: Text(c['label']!, style: const TextStyle(fontSize: 15)),
                          )).toList(),
                        ),
                      );
                      if (sel != null) {
                        await CurrencyNotifier.setSymbol(sel);
                        final sess = await AccountService.sessionPhone();
                        if (sess != null) await AccountService.update(sess, {'currency': sel});
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          StatefulBuilder(
            builder: (ctx, setState) => FutureBuilder<int>(
              future: NotificationService.unreadCount(),
              builder: (ctx, snap) {
                final unread = snap.data ?? 0;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: const Color(0xFFFF7043).withOpacity(0.12), child: const Icon(Icons.notifications_outlined, color: Color(0xFFFF7043))),
                    title: Text(l10n.notifications, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Text(unread > 0 ? '$unread إشعار غير مقروء' : 'كل الإشعارات مقروءة', style: const TextStyle(fontSize: 12)),
                    trailing: unread > 0
                        ? CircleAvatar(radius: 11, backgroundColor: AppTheme.expenseRed, child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
                        : const Icon(Icons.chevron_left, color: Color(0xFFFF7043)),
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          _row(Icons.lock_outline, l10n.appLock, const Color(0xFFE91E63), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupLockScreen()))),
          const Divider(),
          _row(Icons.storage_outlined, l10n.storage, const Color(0xFF00BCD4), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StorageSettingsScreen()))),
          const Divider(),
          _row(Icons.info_outline, l10n.aboutApp, AppTheme.incomeGreen, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
        ],
      ),
    );
  }
}
