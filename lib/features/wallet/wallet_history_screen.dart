import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/wallet_service.dart';
import '../../data/models/app_models.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({super.key});
  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  List<WalletTransaction> _txs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txs = await WalletService.getTransactions();
    if (!mounted) return;
    setState(() { _txs = txs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.walletHistory)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _txs.isEmpty
              ? Center(child: Text(l10n.noTransactions, style: TextStyle(color: Colors.grey.shade500)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _txs.length,
                  itemBuilder: (ctx, i) {
                    final t = _txs[i];
                    final isSend = t.type == 'send';
                    final color = isSend ? AppTheme.expenseRed : AppTheme.incomeGreen;
                    final icon = isSend ? Icons.arrow_upward : (t.type == 'topup' ? Icons.add : Icons.arrow_downward);
                    final label = isSend ? l10n.sent : (t.type == 'topup' ? l10n.toppedUp : l10n.received);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
                        title: Text(label),
                        subtitle: Text('${t.destination} • ${t.date.day}/${t.date.month}/${t.date.year}', style: TextStyle(fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${isSend ? '-' : '+'}${t.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                            Text(t.status, style: TextStyle(fontSize: 10, color: t.status == 'success' ? Colors.green : Colors.red)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
