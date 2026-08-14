import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import 'package:share_plus/share_plus.dart';
import '../shared/amount_calculator_screen.dart';
import '../shared/success_screen.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import '../../core/services/pdf_service.dart';
import 'dart:io';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;
  const ContactDetailsScreen({super.key, required this.contact});
  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  List<DebtTransaction> _txs = [];
  double _balance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  double _signOfType(String type) {
    final isCustomer = widget.contact.type == 'customer';
    return isCustomer ? (type == 'given' ? 1.0 : -1.0) : (type == 'taken' ? 1.0 : -1.0);
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final cid = widget.contact.id.toString();
    final txs = realm.all<DebtTransaction>().toList().where((t) => t.contactId == cid && t.status != 'deleted').toList();
    txs.sort((a, b) => b.date.compareTo(a.date));
    double b = 0;
    for (final t in txs) {
      b += t.amount * _signOfType(t.type);
    }
    if (!mounted) return;
    setState(() {
      _txs = txs;
      _balance = b;
    });
  }

  Future<void> _recompute() async {
    final realm = await RealmService.realm;
    final cid = widget.contact.id.toString();
    final txs = realm.all<DebtTransaction>().toList().where((t) => t.contactId == cid && t.status != 'deleted').toList();
    txs.sort((a, b) => a.date.compareTo(b.date));
    double bal = 0;
    realm.write(() {
      for (final t in txs) {
        bal += t.amount * _signOfType(t.type);
        t.balanceAfter = bal;
      }
    });
    _load();
  }

  Future<void> _manage(DebtTransaction t) async {
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
    } else if (action == 'delete') {
      final realm = await RealmService.realm;
      realm.write(() { t.status = 'deleted'; });
      await _recompute();
    } else if (action == 'share') {
      final label = t.type == 'given' ? l10n.given : l10n.taken;
      await Share.share('$label ${t.amount.toStringAsFixed(2)}\n${widget.contact.name}\n${t.note ?? ''}\n${t.date.day}/${t.date.month}/${t.date.year}');
    }
  }

  Future<void> _addTx(String type) async {
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(type == 'given' ? l10n.given : l10n.taken, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final v = await Navigator.push<double>(context, MaterialPageRoute(builder: (_) => AmountCalculatorScreen(title: type == 'given' ? l10n.given : l10n.taken, color: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen)));
                if (v != null) amountC.text = v.toString();
              },
              child: AbsorbPointer(
                child: TextField(controller: amountC, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen, minimumSize: const Size(double.infinity, 52)),
              onPressed: () async {
                final amount = double.tryParse(amountC.text) ?? 0;
                if (amount <= 0) return;
                final realm = await RealmService.realm;
                final newBalance = _balance + amount * _signOfType(type);
                realm.write(() {
                  realm.add(DebtTransaction(
                    ObjectId(),
                    widget.contact.id.toString(),
                    amount,
                    type,
                    DateTime.now(),
                    newBalance,
                    'active',
                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                  ));
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessScreen(amount: amount, label: type == 'given' ? l10n.given : l10n.taken, color: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen)));
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCustomer = widget.contact.type == 'customer';
    final positive = _balance > 0;
    final color = isCustomer ? (positive ? AppTheme.incomeGreen : AppTheme.expenseRed) : (positive ? AppTheme.expenseRed : AppTheme.incomeGreen);
    final label = isCustomer ? l10n.owedToMe : l10n.owedByMe;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.name),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf_outlined), onPressed: () async {
            final file = await PdfService.generateContactStatement(contact: widget.contact, businessName: 'حساباتي', transactions: _txs);
            if (context.mounted) await Share.shareXFiles([XFile(file.path)], subject: 'Statement - ${widget.contact.name}');
          }),
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.balance, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(label, style: TextStyle(color: color, fontSize: 12)),
                    ],
                  ),
                  Text(_balance.abs().toStringAsFixed(2), style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: _txs.isEmpty
                ? Center(child: Text(l10n.emptyDebtBook, style: TextStyle(color: Colors.grey.shade500)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _txs.length,
                    itemBuilder: (context, i) {
                      final t = _txs[i];
                      final c = t.type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onLongPress: () => _manage(t),
                          leading: Icon(t.type == 'given' ? Icons.arrow_upward : Icons.arrow_downward, color: c),
                          title: Text(t.type == 'given' ? l10n.given : l10n.taken),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${t.date.day}/${t.date.month}/${t.date.year}  ${t.note ?? ''}'),
                              if (t.imagePath != null && t.imagePath!.isNotEmpty && File(t.imagePath!).existsSync())
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(t.imagePath!), height: 60, width: 60, fit: BoxFit.cover)),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(t.amount.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: c)),
                              Text(t.balanceAfter.toStringAsFixed(2), style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
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
          FloatingActionButton.extended(heroTag: 'det_given', backgroundColor: AppTheme.expenseRed, onPressed: () => _addTx('given'), label: Text(l10n.given)),
          const SizedBox(width: 12),
          FloatingActionButton.extended(heroTag: 'det_taken', backgroundColor: AppTheme.incomeGreen, onPressed: () => _addTx('taken'), label: Text(l10n.taken)),
        ],
      ),
    );
  }
}
