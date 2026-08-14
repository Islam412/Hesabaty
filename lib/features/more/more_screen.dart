import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../wallet/wallet_screen.dart';
import 'reminders_screen.dart';
import 'payment_services_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget _bigCard(String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 44, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, {Widget? extra, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.12), child: Icon(icon, color: AppTheme.primaryBlue)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
            if (extra != null) ...[extra, const SizedBox(width: 8)],
            Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 28),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Row(
              children: [
                Text(l10n.more, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.shareApp, style: TextStyle(color: Colors.grey.shade500))),
                CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.12), child: Icon(Icons.share, color: AppTheme.primaryBlue)),
              ],
            ),
            const SizedBox(height: 20),
            _bigCard(
              l10n.myBusinessWallet,
              l10n.walletDesc,
              Icons.account_balance_wallet,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
            ),
            const SizedBox(height: 14),
            _bigCard(l10n.paymentServices, l10n.paymentDesc, Icons.point_of_sale, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentServicesScreen()))),
            const SizedBox(height: 18),
            _row(Icons.work_outline, l10n.businessCard),
            _row(Icons.grid_view_outlined, l10n.inventoryStaff),
            _row(Icons.settings_outlined, l10n.settings, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            _row(Icons.notifications_active_outlined, l10n.reminders, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen()))),
            _row(Icons.backup_outlined, l10n.autoBackup, extra: Icon(Icons.cloud_done, color: AppTheme.incomeGreen, size: 20)),
            _row(Icons.chat_bubble_outline, l10n.contactUs, extra: CircleAvatar(radius: 12, backgroundColor: AppTheme.primaryBlue.withOpacity(0.15), child: Text('0', style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue)))),
            const SizedBox(height: 26),
            Center(child: Text(l10n.aboutApp, style: TextStyle(color: Colors.grey.shade400))),
            const SizedBox(height: 4),
            Center(child: Text(l10n.version + ' 1.0.0', style: TextStyle(color: Colors.grey.shade400))),
          ],
        ),
      ),
    );
  }
}
