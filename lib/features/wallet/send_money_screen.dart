import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../core/services/wallet_service.dart';
import '../../data/models/app_models.dart';
import 'receipt_screen.dart';

class SendMoneyScreen extends StatefulWidget {
  final List<LinkedCard> cards;
  final VoidCallback onDone;
  const SendMoneyScreen({super.key, required this.cards, required this.onDone});
  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String _destType = 'instapay';
  final _destCtrl = TextEditingController();
  final _amtCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  LinkedCard? _card;
  bool _busy = false;

  final _destinations = [
    {'id': 'instapay', 'name': 'InstaPay', 'icon': '⚡', 'color': const Color(0xFF6C5CE7)},
    {'id': 'vodafone', 'name': 'Vodafone Cash', 'icon': '🔴', 'color': const Color(0xFFE60000)},
    {'id': 'orange', 'name': 'Orange Cash', 'icon': '🟠', 'color': const Color(0xFFFF6600)},
    {'id': 'etisalat', 'name': 'Etisalat Cash', 'icon': '🟢', 'color': const Color(0xFF00A651)},
    {'id': 'meeza', 'name': 'Meeza', 'icon': '🇪🇬', 'color': const Color(0xFF1E3A8A)},
    {'id': 'card', 'name': 'Card', 'icon': '💳', 'color': const Color(0xFF2E7CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _card = widget.cards.first;
  }

  Future<void> _send() async {
    if (_card == null) return;
    final amount = double.tryParse(_amtCtrl.text) ?? 0;
    if (amount <= 0) return;
    if (_destCtrl.text.trim().isEmpty) return;
    setState(() => _busy = true);

    final result = await WalletService.send(
      amount: amount,
      destination: _destCtrl.text.trim(),
      destinationType: _destType,
      fromCard: _card!,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _busy = false);
    widget.onDone();

    final dest = _destinations.firstWhere((d) => d['id'] == _destType);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReceiptScreen(
      success: result.success,
      amount: amount,
      destination: _destCtrl.text.trim(),
      destinationLabel: dest['name'] as String,
      reference: result.reference ?? '',
      error: result.error,
      type: 'send',
    )));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sendMoney)),
      body: _busy
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Processing...')]))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.selectDestination, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _destinations.map((d) {
                    final sel = _destType == d['id'];
                    return ChoiceChip(
                      label: Text('${d['icon']}  ${d['name']}'),
                      selected: sel,
                      onSelected: (_) => setState(() => _destType = d['id'] as String),
                      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _destCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                  decoration: InputDecoration(
                    labelText: l10n.cardOrAccount,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amtCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.enterAmount,
                    suffixText: 'ج.م',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.note,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<LinkedCard>(
                  value: _card,
                  decoration: InputDecoration(labelText: l10n.fromCard, border: const OutlineInputBorder()),
                  items: widget.cards.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text('${c.brand} •••• ${c.last4}'),
                  )).toList(),
                  onChanged: (v) => setState(() => _card = v),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _send,
                  child: Text(l10n.confirmSend, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
    );
  }
}
