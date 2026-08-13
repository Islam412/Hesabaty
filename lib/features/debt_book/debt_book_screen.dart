import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'add_contact_screen.dart';
import 'contact_details_screen.dart';

class DebtBookScreen extends StatefulWidget {
  const DebtBookScreen({super.key});
  @override
  State<DebtBookScreen> createState() => _DebtBookScreenState();
}

class _DebtBookScreenState extends State<DebtBookScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Contact> _customers = [];
  List<Contact> _suppliers = [];
  Map<String, double> _balances = {};
  double _owedToMe = 0;
  double _owedByMe = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final all = realm.all<Contact>().toList().where((c) => !c.isDeleted).toList();
    final txs = realm.all<DebtTransaction>().toList().where((t) => t.status != 'deleted').toList();
    final balances = <String, double>{};
    double owedToMe = 0;
    double owedByMe = 0;
    for (final c in all) {
      final cid = c.id.toString();
      double b = 0;
      for (final t in txs) {
        if (t.contactId != cid) continue;
        final sign = c.type == 'customer' ? (t.type == 'given' ? 1.0 : -1.0) : (t.type == 'taken' ? 1.0 : -1.0);
        b += t.amount * sign;
      }
      balances[cid] = b;
      if (c.type == 'customer' && b > 0) owedToMe += b;
      if (c.type == 'supplier' && b > 0) owedByMe += b;
    }
    if (!mounted) return;
    setState(() {
      _balances = balances;
      _customers = all.where((c) => c.type == 'customer').toList();
      _suppliers = all.where((c) => c.type == 'supplier').toList();
      _owedToMe = owedToMe;
      _owedByMe = owedByMe;
    });
  }

  Widget _summaryCard(String title, double value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value.toStringAsFixed(2), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCustomers = _tab.index == 0;
    final list = (isCustomers ? _customers : _suppliers).where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtBook),
        bottom: TabBar(controller: _tab, tabs: [Tab(text: l10n.customers), Tab(text: l10n.suppliers)]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _summaryCard(l10n.owedToMe, _owedToMe, AppTheme.incomeGreen)),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard(l10n.owedByMe, _owedByMe, AppTheme.expenseRed)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(hintText: l10n.search, prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(l10n.emptyDebtBook, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final c = list[i];
                      final bal = _balances[c.id.toString()] ?? 0;
                      final positive = bal > 0;
                      final color = c.type == 'customer' ? (positive ? AppTheme.incomeGreen : AppTheme.expenseRed) : (positive ? AppTheme.expenseRed : AppTheme.incomeGreen);
                      final label = c.type == 'customer' ? l10n.owedToMe : l10n.owedByMe;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => ContactDetailsScreen(contact: c)));
                            _load();
                          },
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                            child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(label, style: TextStyle(color: color, fontSize: 12)),
                          trailing: Text(bal.abs().toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddContactScreen(isSupplier: !isCustomers)));
          if (result == true) _load();
        },
        label: Text(isCustomers ? l10n.addCustomer : l10n.addSupplier),
        icon: const Icon(Icons.person_add_alt),
      ),
    );
  }
}
