import 'dart:math';
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
  final _bankCtrl = TextEditingController();
  bool _showBanks = false;
  bool _busy = false;

  static const List<String> _banks = [
    'Banque Misr - بنك مصر',
    'National Bank of Egypt - البنك الأهلي المصري',
    'CIB - البنك التجاري الدولي',
    'QNB AlAhli - بنك قطر الوطني الأهلي',
    'Banque du Caire - بنك القاهرة',
    'Alex Bank - بنك الإسكندرية',
    'Arab African International Bank - البنك العربي الأفريقي',
    'Housing & Development Bank - بنك التعمير والإسكان',
    'Crédit Agricole Egypt - بنك كريدي أجريكول',
    'Faisal Islamic Bank - بنك فيصل الإسلامي',
    'Abu Dhabi Islamic Bank - مصرف أبوظبي الإسلامي',
    'Emirates NBD - بنك الإمارات دبي الوطني',
    'MIDBANK - ميدبنك',
    'saib Bank - بنك سايب',
    'Suez Canal Bank - بنك قناة السويس',
    'Al Baraka Bank - بنك البركة',
    'Al Ahly United Bank - البنك الأهلي المتحد',
    'Export Development Bank - بنك تنمية الصادرات',
  ];

  List<String> get _filteredBanks {
    final q = _bankCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _banks;
    return _banks.where((b) => b.toLowerCase().contains(q)).toList();
  }

  void _save() async {
    final l10n = AppLocalizations.of(context)!;
    final num = _numCtrl.text.replaceAll(RegExp(r'\D'), '');
    String? err;
    if (!WalletService.luhnCheck(num)) {
      err = l10n.cardNumberInvalid;
    } else if (_nameCtrl.text.trim().isEmpty) {
      err = l10n.cardHolderRequired;
    } else if (!WalletService.validExpiry(_expCtrl.text.trim())) {
      err = l10n.expiryInvalid;
    } else if (_cvvCtrl.text.trim().length < 3) {
      err = l10n.cvvInvalid;
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppTheme.expenseRed));
      return;
    }
    setState(() => _busy = true);
    try {
      final balance = 10000 + Random().nextInt(40000) * 1.0;
      await WalletService.addCard(
        number: num,
        name: _nameCtrl.text.trim(),
        expiry: _expCtrl.text.trim(),
        cvv: _cvvCtrl.text.trim(),
        bank: _bankCtrl.text.trim().isEmpty ? null : _bankCtrl.text.trim(),
        balance: balance,
      );
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l10n.cardAdded} — الرصيد: ${balance.toStringAsFixed(2)} ${Cur.v}'),
        backgroundColor: AppTheme.incomeGreen,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('خطأ: $e'),
        backgroundColor: AppTheme.expenseRed,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brand = WalletService.detectBrand(_numCtrl.text);
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
            height: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(_bankCtrl.text.isEmpty ? brand : _bankCtrl.text.split(' - ').first, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    Text(brand, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text(
                  _numCtrl.text.isEmpty ? '•••• •••• •••• ••••' : _numCtrl.text,
                  style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_nameCtrl.text.isEmpty ? 'CARDHOLDER' : _nameCtrl.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13)),
                    Text(_expCtrl.text.isEmpty ? 'MM/YY' : _expCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _numCtrl,
            textDirection: TextDirection.ltr,
            textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              TextInputFormatter.withFunction((oldV, newV) {
                final t = newV.text;
                final buf = StringBuffer();
                for (int i = 0; i < t.length; i++) {
                  if (i > 0 && i % 4 == 0) buf.write('\u200E \u200E');
                  buf.write(t[i]);
                }
                return TextEditingValue(text: buf.toString(), selection: TextSelection.collapsed(offset: buf.length));
              }),
            ],
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
          TextField(
            controller: _bankCtrl,
            onTap: () => setState(() => _showBanks = true),
            onChanged: (_) => setState(() => _showBanks = true),
            decoration: InputDecoration(
              labelText: l10n.bankName,
              border: const OutlineInputBorder(),
              suffixIcon: _showBanks
                  ? IconButton(icon: const Icon(Icons.arrow_drop_up), onPressed: () => setState(() => _showBanks = false))
                  : IconButton(icon: const Icon(Icons.arrow_drop_down), onPressed: () => setState(() => _showBanks = true)),
            ),
          ),
          if (_showBanks)
            Material(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _filteredBanks.isEmpty
                    ? const Padding(padding: EdgeInsets.all(12), child: Center(child: Text('—')))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredBanks.length,
                        itemBuilder: (ctx, i) {
                          final b = _filteredBanks[i];
                          return InkWell(
                            onTap: () {
                              _bankCtrl.text = b;
                              setState(() => _showBanks = false);
                              FocusScope.of(context).nextFocus();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Text(b, style: const TextStyle(fontSize: 14)),
                            ),
                          );
                        },
                      ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expCtrl,
            textDirection: TextDirection.ltr,
            textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    TextInputFormatter.withFunction((oldV, newV) {
                      final t = newV.text;
                      String text;
                      if (t.length <= 2) {
                        text = t;
                      } else {
                        text = '${t.substring(0, 2)}/${t.substring(2)}';
                      }
                      return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
                    }),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.expiryDate,
                    hintText: 'MM/YY',
                    border: const OutlineInputBorder(),
                    counterText: '',
                    suffixIcon: _expCtrl.text.length == 5
                        ? Icon(WalletService.validExpiry(_expCtrl.text) ? Icons.check_circle : Icons.error, color: WalletService.validExpiry(_expCtrl.text) ? AppTheme.incomeGreen : AppTheme.expenseRed, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvvCtrl,
            textDirection: TextDirection.ltr,
            textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
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
            onPressed: _busy ? null : _save,
            child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(l10n.addCard, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
