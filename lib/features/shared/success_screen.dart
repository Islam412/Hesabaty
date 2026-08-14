import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/theme.dart';

class SuccessScreen extends StatelessWidget {
  final double amount;
  final String label;
  final Color color;
  const SuccessScreen({super.key, required this.amount, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(l10n.txSuccess, textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Text('حساباتي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                    const SizedBox(height: 6),
                    Text('${now.day}/${now.month}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(height: 20),
                    Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${amount.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(width: 8),
                        Text('Hesabaty', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                      onPressed: () => Share.share('$label: ${amount.toStringAsFixed(2)} ج.م'),
                      child: Text(l10n.share, style: const TextStyle(fontSize: 17)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue.withOpacity(0.15), foregroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.finish, style: const TextStyle(fontSize: 17)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
