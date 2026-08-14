import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/account_service.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../core/services/share_service.dart';
import '../../core/services/statement_link_service.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'bills_screen.dart';

class PaymentServicesScreen extends StatefulWidget {
  const PaymentServicesScreen({super.key});
  @override
  State<PaymentServicesScreen> createState() => _PaymentServicesScreenState();
}

class _PaymentServicesScreenState extends State<PaymentServicesScreen> {
  static const List<Map<String, String>> _methods = [
    {'id': 'vodafone', 'label': 'فودافون كاش', 'icon': '🔴', 'hint': 'رقم فودافون كاش'},
    {'id': 'instapay', 'label': 'انستا باي', 'icon': '⚡', 'hint': 'عنوان انستا باي'},
    {'id': 'fawry', 'label': 'فوري', 'icon': '🟡', 'hint': 'رقم فوري'},
    {'id': 'card', 'label': 'بطاقة بنكية', 'icon': '💳', 'hint': 'رقم البطاقة'},
    {'id': 'wallet', 'label': 'محفظة إلكترونية', 'icon': '👛', 'hint': 'رقم المحفظة'},
  ];

  Map<String, bool> _enabled = {};
  Map<String, String> _accounts = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await AccPrefs.scoped();
    setState(() {
      _enabled = Map<String, bool>.from(jsonDecode(prefs.getString('pay_enabled') ?? '{}'));
      _accounts = Map<String, String>.from(jsonDecode(prefs.getString('pay_accounts') ?? '{}'));
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await AccPrefs.scoped();
    await prefs.setString('pay_enabled', jsonEncode(_enabled));
    await prefs.setString('pay_accounts', jsonEncode(_accounts));
  }

  Future<void> _createLink() async {
    final l10n = AppLocalizations.of(context)!;
    final realm = await RealmService.realm;
    final customers = realm.all<Contact>().where((c) => c.type == 'customer' && !c.isDeleted).toList();
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ضيف عميل الأول من دفتر الديون')));
      return;
    }
    final contact = await showDialog<Contact>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.chooseCustomer),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (c, i) => ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.primaryBlue.withOpacity(0.15), child: Text(customers[i].name.isNotEmpty ? customers[i].name[0] : '?')),
              title: Text(customers[i].name),
              onTap: () => Navigator.pop(ctx, customers[i]),
            ),
          ),
        ),
      ),
    );
    if (contact == null) return;

    final cid = contact.id.toString();
    final txs = realm.all<DebtTransaction>().toList().where((t) => t.contactId == cid && t.status != 'deleted').toList();
    double bal = 0;
    for (final t in txs) {
      bal += t.amount * (t.type == 'given' ? 1.0 : -1.0);
    }

    final payMethods = _methods
        .where((m) => _enabled[m['id']] == true)
        .map((m) => {'label': m['label']!, 'account': _accounts[m['id']] ?? ''})
        .toList();

    final link = await StatementLinkService.generateLink(contact, txs, bal, payMethods: payMethods);
    if (!mounted) return;
    await ShareService.shareText(context, '💳 رابط تحصيل\n${contact.name}: ${bal.abs().toStringAsFixed(2)} ج.م\n${l10n.seeAllTransactions}\n$link');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.linkReady), backgroundColor: AppTheme.incomeGreen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentServices)),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
                    ),
                    title: const Text('دفع الفواتير والشحن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: const Text('كهرباء، غاز، مياه، تليفون، نت، شحن رصيد...'),
                    trailing: const Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 28),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsScreen())),
                  ),
                ),
                Text(l10n.paymentMethods, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._methods.map((m) {
                  final ctrl = TextEditingController(text: _accounts[m['id']] ?? '');
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        SwitchListTile(
                          secondary: Text(m['icon']!, style: const TextStyle(fontSize: 26)),
                          title: Text(m['label']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                          value: _enabled[m['id']] == true,
                          onChanged: (v) async {
                            setState(() => _enabled[m['id']!] = v);
                            await _save();
                          },
                        ),
                        if (_enabled[m['id']] == true)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: TextField(
                              controller: ctrl,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(labelText: m['hint'], border: const OutlineInputBorder()),
                              onChanged: (v) async {
                                _accounts[m['id']!] = v;
                                await _save();
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: _createLink,
                  icon: const Icon(Icons.link),
                  label: Text(l10n.createPaymentLink, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
    );
  }
}
