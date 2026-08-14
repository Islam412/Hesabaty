import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/wallet_service.dart';
import '../../data/models/app_models.dart';
import 'receipt_screen.dart';

class TopUpScreen extends StatefulWidget {
  final List<LinkedCard> cards;
  final VoidCallback onDone;
  const TopUpScreen({super.key, required this.cards, required this.onDone});
  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amtCtrl = TextEditingController();
  LinkedCard? _card;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _card = widget.cards.first;
  }

  Future<void> _topUp() async {
    if (_card == null) return;
    final amount = double.tryParse(_amtCtrl.text) ?? 0;
    if (amount <= 0) return;
    setState(() => _busy = true);
    final result = await WalletService.topUp(amount: amount, fromCard: _card!);
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onDone();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReceiptScreen(
      success: result.success,
      amount: amount,
      destination: '${_card!.brand} •••• ${_card!.last4}',
      destinationLabel: 'Top up',
      reference: result.reference ?? '',
      error: result.error,
      type: 'topup',
    )));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.topUp)),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _amtCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: Cur.v,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<LinkedCard>(
                    value: _card,
                    decoration: InputDecoration(labelText: l10n.fromCard, border: const OutlineInputBorder()),
                    items: widget.cards.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.brand} •••• ${c.last4}'),
                    )).toList(),
                    onChanged: (v) => setState(() => _card = v),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    onPressed: _topUp,
                    child: Text(l10n.topUp, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}
