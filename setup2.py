import os

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

realm_service_dart = """import 'package:realm/realm.dart';
import '../models/app_models.dart';

class RealmService {
  static Realm? _realm;

  static Future<Realm> get realm async {
    if (_realm != null && !_realm!.isClosed) return _realm!;
    
    final config = Configuration.local(
      [
        Business.schema,
        Contact.schema,
        CashTransaction.schema,
        DebtTransaction.schema,
        Reminder.schema,
      ],
      schemaVersion: 1,
    );
    
    _realm = Realm(config);
    return _realm!;
  }
}
"""

cash_book_dart = """import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import '../../app/theme.dart';

class CashBookScreen extends ConsumerStatefulWidget {
  const CashBookScreen({super.key});

  @override
  ConsumerState<CashBookScreen> createState() => _CashBookScreenState();
}

class _CashBookScreenState extends ConsumerState<CashBookScreen> {
  double totalIncome = 0;
  double totalExpense = 0;
  double balance = 0;
  List<CashTransaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final realm = await RealmService.realm;
    final allTransactions = realm.all<CashTransaction>().toList();
    
    double income = 0;
    double expense = 0;
    
    for (var tx in allTransactions) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    
    setState(() {
      transactions = allTransactions.reversed.toList();
      totalIncome = income;
      totalExpense = expense;
      balance = income - expense;
    });
  }

  void _showAddSheet(BuildContext context, String type) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              type == 'income' ? '+ ${l10n.income}' : '- ${l10n.expense}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: type == 'income' ? AppTheme.incomeGreen : AppTheme.expenseRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.balance,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: l10n.more,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: type == 'income' ? AppTheme.incomeGreen : AppTheme.expenseRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (amountController.text.isEmpty) return;
                
                final realm = await RealmService.realm;
                final amount = double.tryParse(amountController.text) ?? 0;
                
                realm.write(() {
                  realm.add(CashTransaction(
                    ObjectId(),
                    'business_1',
                    amount,
                    type,
                    noteController.text,
                    null,
                    DateTime.now(),
                    balance + (type == 'income' ? amount : -amount),
                    'active',
                  ));
                });
                
                Navigator.pop(ctx);
                _loadData();
              },
              child: Text(l10n.save),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cashBook)),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.income, style: TextStyle(color: AppTheme.incomeGreen)),
                      Text('+${totalIncome.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.incomeGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.expense, style: TextStyle(color: AppTheme.expenseRed)),
                      Text('-${totalExpense.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.balance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(balance.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? Center(child: Text(l10n.emptyCashBook))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isIncome = tx.type == 'income';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                            color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                          ),
                          title: Text(tx.note ?? ''),
                          subtitle: Text('${tx.amount.toStringAsFixed(2)}'),
                          trailing: Text(
                            isIncome ? '+' : '-',
                            style: TextStyle(
                              color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            backgroundColor: AppTheme.incomeGreen,
            onPressed: () => _showAddSheet(context, 'income'),
            label: Text('+ ${l10n.income}'),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            backgroundColor: AppTheme.expenseRed,
            onPressed: () => _showAddSheet(context, 'expense'),
            label: Text('- ${l10n.expense}'),
          ),
        ],
      ),
    );
  }
}
"""

write_file('lib/data/services/realm_service.dart', realm_service_dart)
write_file('lib/features/cash_book/cash_book_screen.dart', cash_book_dart)

print("✅ Realm Service & Cash Book Screen created successfully!")
