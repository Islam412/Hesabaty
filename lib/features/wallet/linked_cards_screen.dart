import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/wallet_service.dart';
import '../../data/models/app_models.dart';
import 'add_card_screen.dart';

class LinkedCardsScreen extends StatefulWidget {
  const LinkedCardsScreen({super.key});
  @override
  State<LinkedCardsScreen> createState() => _LinkedCardsScreenState();
}

class _LinkedCardsScreenState extends State<LinkedCardsScreen> {
  List<LinkedCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await WalletService.getCards();
    if (!mounted) return;
    setState(() => _cards = cards);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.linkedCards)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardScreen()));
          _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        itemBuilder: (ctx, i) {
          final c = _cards[i];
          return Dismissible(
            key: Key(c.id),
            direction: DismissDirection.endToStart,
            background: Container(color: AppTheme.expenseRed, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) async {
              await WalletService.removeCard(c.id);
              _load();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('💳', style: TextStyle(fontSize: 24, color: Colors.white)),
                      Text(c.brand, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('•••• •••• •••• ${c.last4}', style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.cardholderName.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      Text(c.expiry, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
