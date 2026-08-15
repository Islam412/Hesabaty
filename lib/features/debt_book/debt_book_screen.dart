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
  Map<String, DateTime> _lastActive = {};
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
    final lastActive = <String, DateTime>{};
    double owedToMe = 0;
    double owedByMe = 0;
    for (final t in txs) {
      final cur = lastActive[t.contactId];
      if (cur == null || t.date.isAfter(cur)) lastActive[t.contactId] = t.date;
    }
    for (final c in all) {
      final cid = c.id.toString();
      double b = 0;
      for (final t in txs) {
        if (t.contactId != cid) continue;
        final sign = (c.isValid && (c.isValid && c.type == 'customer')) ? (t.type == 'given' ? 1.0 : -1.0) : (t.type == 'taken' ? 1.0 : -1.0);
        b += t.amount * sign;
      }
      balances[cid] = b;
      if (c.isValid && c.type == 'customer') { if (b < 0) owedToMe += -b; else owedByMe += b; }
      if (c.isValid && c.type == 'supplier') { if (b > 0) owedByMe += b; else owedToMe += -b; }
    }
    if (!mounted) return;
    setState(() {
      _balances = balances;
      _lastActive = lastActive;
      _customers = all.where((c) => (c.isValid && (c.isValid && c.type == 'customer'))).toList();
      _suppliers = all.where((c) => (c.isValid && (c.isValid && c.type == 'supplier'))).toList();
      _owedToMe = owedToMe;
      _owedByMe = owedByMe;
    });
  }

  String _rel(BuildContext context, DateTime d) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final days = DateTime.now().difference(d).inDays;
    if (days <= 0) return ar ? 'اليوم' : 'Today';
    if (days == 1) return ar ? 'منذ يوم' : '1 day ago';
    return ar ? 'منذ $days يوم' : '$days days ago';
  }

  Future<void> _openAdd(bool isSupplier) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddContactScreen(isSupplier: isSupplier)));
    if (result == true) _load();
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

  Widget _empty(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        Center(child: Icon(Icons.auto_stories_rounded, size: 140, color: AppTheme.primaryBlue.withOpacity(0.35))),
        const SizedBox(height: 24),
        Center(child: Text(l10n.emptyDebtBook, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.grey.shade500))),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _openAdd(true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(l10n.addSupplier, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _openAdd(false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(l10n.addCustomer, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  double _calcOwedToMe() {
    double s = 0;
    for (final c in [..._customers, ..._suppliers]) {
      final b = _balances[c.id.toString()] ?? 0;
      if (b < 0) s += -b;
    }
    return s;
  }

  double _calcOwedByMe() {
    double s = 0;
    for (final c in [..._customers, ..._suppliers]) {
      final b = _balances[c.id.toString()] ?? 0;
      if (b > 0) s += b;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCustomers = _tab.index == 0;
    final list = (isCustomers ? _customers : _suppliers).where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();
    final isEmpty = _customers.isEmpty && _suppliers.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtBook),
        bottom: TabBar(controller: _tab, tabs: [Tab(text: l10n.customers), Tab(text: l10n.suppliers)]),
      ),
      body: isEmpty
          ? _empty(l10n)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _summaryCard(l10n.owedToMe, _calcOwedToMe(), AppTheme.incomeGreen)),
                      const SizedBox(width: 12),
                      Expanded(child: _summaryCard(l10n.owedByMe, _calcOwedByMe(), AppTheme.expenseRed)),
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
                            final color = (c.isValid && (c.isValid && c.type == 'customer')) ? (positive ? AppTheme.incomeGreen : AppTheme.expenseRed) : (positive ? AppTheme.expenseRed : AppTheme.incomeGreen);
                            final label = (c.isValid && (c.isValid && c.type == 'customer')) ? l10n.owedToMe : l10n.owedByMe;
                            final last = _lastActive[c.id.toString()];
                            final subtitle = last == null ? label : '$label  •  ${_rel(context, last)}';
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
                                subtitle: Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
                                trailing: Text(bal.abs().toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'debt_add',
        onPressed: () => _openAdd(!isCustomers),
        label: Text(isCustomers ? l10n.addCustomer : l10n.addSupplier),
        icon: const Icon(Icons.person_add_alt),
      ),
    );
  }
}
