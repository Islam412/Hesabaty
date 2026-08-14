import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/wallet_service.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _numCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  void _save() async {
    final l10n = AppLocalizations.of(context)!;
    final num = _numCtrl.text.replaceAll(' ', '');
    if (!WalletService.luhnCheck(num)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid card number')));
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) return;
    if (_expCtrl.text.trim().length < 5) return;
    if (_cvvCtrl.text.trim().length < 3) return;

    await WalletService.addCard(
      number: num,
      name: _nameCtrl.text.trim(),
      expiry: _expCtrl.text.trim(),
      cvv: _cvvCtrl.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cardAdded), backgroundColor: AppTheme.incomeGreen));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCard)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF1E5BB8)]),
              borderRadius: BorderRadius.circular(16),
            ),
            height: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('💳', style: TextStyle(fontSize: 32)), Text('VISA', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))],
                ),
                Text(_numCtrl.text.isEmpty ? '•••• •••• •••• ••••' : _numCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_nameCtrl.text.isEmpty ? 'CARDHOLDER' : _nameCtrl.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                    Text(_expCtrl.text.isEmpty ? 'MM/YY' : _expCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _numCtrl,
            keyboardType: TextInputType.number,
            maxLength: 19,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.cardNumber, border: const OutlineInputBorder(), counterText: ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.cardholderName, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    TextInputFormatter.withFunction((oldV, newV) {
                      final t = newV.text;
                      if (t.length == 2 && oldV.text.length < 2) {
                        return TextEditingValue(text: '$t/', selection: const TextSelection.collapsed(offset: 3));
                      }
                      return newV;
                    }),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(labelText: l10n.expiryDate, hintText: 'MM/YY', border: const OutlineInputBorder(), counterText: ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l10n.cvv, border: const OutlineInputBorder(), counterText: ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _save,
            child: Text(l10n.addCard, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
