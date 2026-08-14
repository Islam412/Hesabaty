import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import 'package:share_plus/share_plus.dart';
import '../shared/amount_calculator_screen.dart';
import '../shared/success_screen.dart';
import '../shared/transaction_details_screen.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import '../../core/services/image_picker_service.dart';
import 'dart:io';

class CashBookScreen extends StatefulWidget {
  const CashBookScreen({super.key});
  @override
  State<CashBookScreen> createState() => _CashBookScreenState();
}

class _CashBookScreenState extends State<CashBookScreen> {
  double _income = 0;
  double _expense = 0;
  double _balance = 0;
  bool _hide = false;
  List<CashTransaction> _txs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final all = realm.all<CashTransaction>().toList().where((t) => t.status != 'deleted').toList();
    all.sort((a, b) => b.date.compareTo(a.date));
    double income = 0;
    double expense = 0;
    for (final t in all) {
      if (t.type == 'income') { income += t.amount; } else { expense += t.amount; }
    }
    if (!mounted) return;
    setState(() {
      _txs = all;
      _income = income;
      _expense = expense;
      _balance = income - expense;
    });
  }

  String _fmt(double v) => _hide ? '••••' : v.toStringAsFixed(2);

  Future<void> _recompute() async {
    final realm = await RealmService.realm;
    final active = realm.all<CashTransaction>().toList().where((t) => t.status != 'deleted').toList();
    active.sort((a, b) => a.date.compareTo(b.date));
    double bal = 0;
    realm.write(() {
      for (final t in active) {
        bal += t.type == 'income' ? t.amount : -t.amount;
        t.balanceAfter = bal;
      }
    });
    _load();
  }

  Future<void> _add(String type) async {
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String? _imgPath;
    final l10n = AppLocalizations.of(context)!;
    final isIncome = type == 'income';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isIncome ? '+ ${l10n.income}' : '- ${l10n.expense}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final v = await Navigator.push<double>(context, MaterialPageRoute(builder: (_) => AmountCalculatorScreen(title: isIncome ? l10n.income : l10n.expense, color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed)));
                if (v != null) amountC.text = v.toString();
              },
              child: AbsorbPointer(
                child: TextField(controller: amountC, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
            StatefulBuilder(
              builder: (ctx, setS) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(context: ctx, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 30)));
                          if (d != null) setS(() => selectedDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 6),
                            Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontSize: 14)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                          if (t != null) setS(() => selectedTime = t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 6),
                            Text('${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontSize: 14)),
                          ]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StatefulBuilder(
              builder: (ctx, setS) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: FilledButton.tonalIcon(onPressed: () async { final p = await ImagePickerService.pickAndSave(fromCamera: true); if (p != null) setS(() => _imgPath = p); }, icon: const Icon(Icons.camera_alt, size: 18), label: const Text('كاميرا'))),
                        const SizedBox(width: 8),
                        Expanded(child: FilledButton.tonalIcon(onPressed: () async { final p = await ImagePickerService.pickAndSave(fromCamera: false); if (p != null) setS(() => _imgPath = p); }, icon: const Icon(Icons.photo_library, size: 18), label: const Text('معرض'))),
                      ],
                    ),
                    if (_imgPath != null) ...[
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imgPath!), height: 120, width: double.infinity, fit: BoxFit.cover)),
                          Positioned(top: 4, right: 4, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setS(() => _imgPath = null), style: IconButton.styleFrom(backgroundColor: Colors.black54))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed, minimumSize: const Size(double.infinity, 52)),
              onPressed: () async {
                final amount = double.tryParse(amountC.text) ?? 0;
                if (amount <= 0) return;
                final realm = await RealmService.realm;
                final newBalance = _balance + (isIncome ? amount : -amount);
                realm.write(() {
                  realm.add(CashTransaction(
                    ObjectId(),
                    'business_1',
                    amount,
                    type,
                    DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                    newBalance,
                    'active',
                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                    imagePath: _imgPath,
                  ));
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessScreen(amount: amount, label: isIncome ? l10n.income : l10n.expense, color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed)));
                }
                _load();
              },
              child: Text(l10n.save),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _manage(CashTransaction t) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.edit, color: AppTheme.primaryBlue), title: Text(l10n.edit), onTap: () => Navigator.pop(ctx, 'edit')),
            ListTile(leading: Icon(Icons.share, color: AppTheme.primaryBlue), title: Text(l10n.share), onTap: () => Navigator.pop(ctx, 'share')),
            ListTile(leading: Icon(Icons.delete_outline, color: AppTheme.expenseRed), title: Text(l10n.voidTx), onTap: () => Navigator.pop(ctx, 'delete')),
          ],
        ),
      ),
    );
    if (action == 'edit') {
      await _edit(t);
    } else if (action == 'delete') {
      final realm = await RealmService.realm;
      realm.write(() { t.status = 'deleted'; });
      await _recompute();
    } else if (action == 'share') {
      final sign = t.type == 'income' ? '+' : '-';
      await Share.share('$sign ${t.amount.toStringAsFixed(2)}\n${t.note ?? ''}\n${t.date.day}/${t.date.month}/${t.date.year}');
    }
  }

  Future<void> _edit(CashTransaction t) async {
    final l10n = AppLocalizations.of(context)!;
    final amountC = TextEditingController(text: t.amount.toString());
    final noteC = TextEditingController(text: t.note ?? '');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.edit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount)),
            const SizedBox(height: 8),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountC.text) ?? t.amount;
              final realm = await RealmService.realm;
              realm.write(() {
                t.amount = amount;
                t.note = noteC.text.trim().isEmpty ? null : noteC.text.trim();
                t.status = 'edited';
              });
              Navigator.pop(ctx);
              await _recompute();
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _bigButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(label, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _empty(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Center(child: Icon(Icons.auto_stories_rounded, size: 140, color: AppTheme.primaryBlue.withOpacity(0.35))),
        const SizedBox(height: 24),
        Center(child: Text(l10n.emptyCashBook, textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.grey.shade500))),
        const SizedBox(height: 8),
        const Center(child: Text('👇', style: TextStyle(fontSize: 28))),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _bigButton(l10n.income, AppTheme.incomeGreen, () => _add('income'))),
            const SizedBox(width: 12),
            Expanded(child: _bigButton(l10n.expense, AppTheme.expenseRed, () => _add('expense'))),
          ],
        ),
      ],
    );
  }

  Widget _list(AppLocalizations l10n) {
    return Column(
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
                    Text(_fmt(_income), style: TextStyle(color: AppTheme.incomeGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.expense, style: TextStyle(color: AppTheme.expenseRed)),
                    Text(_fmt(_expense), style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.balance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(_fmt(_balance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _txs.length,
            itemBuilder: (context, i) {
              final t = _txs[i];
              final isIncome = t.type == 'income';
              final color = isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(
                        amount: t.amount,
                        date: t.date,
                        note: t.note,
                        imagePath: t.imagePath,
                        color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
                        title: isIncome ? l10n.income : l10n.expense,
                        onEdit: () { Navigator.of(context).pop(); _edit(t); },
                        onDelete: () async { Navigator.of(context).pop(); final realm = await RealmService.realm; realm.write(() { t.status = 'deleted'; }); await _recompute(); },
                      ))),
                  onLongPress: () => _manage(t),
                  leading: Icon(isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline, color: color),
                  title: Text(t.note ?? (isIncome ? l10n.income : l10n.expense)),
                  subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}'),
                  trailing: Text('${isIncome ? '+' : '-'} ${_fmt(t.amount)}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cashBook),
        actions: [
          IconButton(
            icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _hide = !_hide),
          ),
        ],
      ),
      body: _txs.isEmpty ? _empty(l10n) : _list(l10n),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(heroTag: 'cash_inc', backgroundColor: AppTheme.incomeGreen, onPressed: () => _add('income'), label: Text('+ ${l10n.income}')),
          const SizedBox(width: 12),
          FloatingActionButton.extended(heroTag: 'cash_exp', backgroundColor: AppTheme.expenseRed, onPressed: () => _add('expense'), label: Text('- ${l10n.expense}')),
        ],
      ),
    );
  }
}
