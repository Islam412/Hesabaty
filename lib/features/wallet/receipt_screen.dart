import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/receipt_image_service.dart';
import '../../core/services/share_service.dart';

class ReceiptScreen extends StatelessWidget {
  final bool success;
  final double amount;
  final String destination;
  final String destinationLabel;
  final String reference;
  final String? error;
  final String type;
  const ReceiptScreen({
    super.key,
    required this.success,
    required this.amount,
    required this.destination,
    required this.destinationLabel,
    required this.reference,
    this.error,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(success ? Icons.check_circle : Icons.cancel, color: success ? AppTheme.incomeGreen : AppTheme.expenseRed, size: 96),
            const SizedBox(height: 16),
            Text(success ? l10n.transactionSuccess : l10n.transactionFailed, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            if (error != null) Padding(padding: const EdgeInsets.all(16), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('${amount.toStringAsFixed(2)} ج.م', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('$destinationLabel: $destination', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('${l10n.referenceNumber}: $reference', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (success)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () async {
                          final path = await ReceiptImageService.generateReceiptImage(
                            businessName: 'حساباتي',
                            title: type == 'send' ? l10n.sent : (type == 'bill' ? 'دفع فاتورة' : l10n.toppedUp),
                            amount: amount,
                            amountColor: type == 'send' ? AppTheme.expenseRed : AppTheme.incomeGreen,
                          );
                          if (context.mounted) {
                            await ShareService.shareReceiptImage(context, path, '${l10n.sent}: ${amount.toStringAsFixed(2)} ج.م\nإلى: $destination\nمرجع: $reference');
                          }
                        },
                        icon: const Icon(Icons.share),
                        label: Text(l10n.shareReceipt),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                  foregroundColor: AppTheme.primaryBlue,
                  minimumSize: const Size(double.infinity, 52),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.finish),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
