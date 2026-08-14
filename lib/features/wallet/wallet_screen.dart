import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/wallet_service.dart';
import '../../data/models/app_models.dart';
import 'add_card_screen.dart';
import 'send_money_screen.dart';
import 'top_up_screen.dart';
import 'wallet_history_screen.dart';
import 'linked_cards_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0;
  List<LinkedCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bal = await WalletService.getBalance();
    final cards = await WalletService.getCards();
    if (!mounted) return;
    setState(() { _balance = bal; _cards = cards; });
  }

  String _brandIcon(String brand) {
    final b = brand.toLowerCase();
    if (b.contains('visa')) return '💳';
    if (b.contains('master')) return '💳';
    if (b.contains('meeza')) return '🇪🇬';
    return '💳';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultCard = _cards.isNotEmpty ? _cards.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myWallet),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletHistoryScreen()));
            _load();
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.availableBalance, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('${_balance.toStringAsFixed(2)} ${Cur.v}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryBlue),
                          onPressed: () async {
                            if (_cards.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.addCard)));
                              return;
                            }
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => SendMoneyScreen(cards: _cards, onDone: _load)));
                          },
                          icon: const Icon(Icons.arrow_upward),
                          label: Text(l10n.sendMoney),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                          onPressed: () async {
                            if (_cards.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.addCard)));
                              return;
                            }
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => TopUpScreen(cards: _cards, onDone: _load)));
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.topUp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.linkedCards, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardScreen()));
                    _load();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addCard),
                ),
              ],
            ),
            if (_cards.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.credit_card, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(l10n.addCard, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ..._cards.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Text(_brandIcon(c.brand), style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c.brand} •••• ${c.last4}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${c.bank ?? ''}  ${c.expiry}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          if (c.balance != null) Text('الرصيد: ${c.balance!.toStringAsFixed(2)} ${Cur.v}', style: TextStyle(color: AppTheme.incomeGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}
