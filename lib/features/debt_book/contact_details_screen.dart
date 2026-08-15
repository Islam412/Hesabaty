import '../../core/widgets/calculator_sheet.dart';
import '../../core/widgets/statement_card.dart';
import '../more/image_export_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/services/pdf_service.dart';
import '../../core/services/receipt_image_service.dart';
import '../../core/services/share_service.dart';
import '../../core/services/statement_link_service.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import '../shared/report_period_sheet.dart';
import '../shared/transaction_details_screen.dart';
import 'schedule_reminder_screen.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;
  const ContactDetailsScreen({super.key, required this.contact});
  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  List<DebtTransaction> _txs = [];
  double _balance = 0;
  bool _showInfo = false;

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

  Future<void> _shareContact() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageExportScreen(
          child: ContactStatementCard(contact: widget.contact),
          fileName: 'statement_${widget.contact.name}',
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    final res = await showModalBottomSheet<Object>(context: context, builder: (_) => const ReportPeriodSheet());
    if (res == null) return;
    DateTime? from;
    DateTime? to;
    if (res is DateTimeRange) {
      from = res.start;
      to = res.end;
    }
    final filtered = _txs.where((t) {
      if (from != null && t.date.isBefore(from!)) return false;
      if (to != null && t.date.isAfter(to!.add(const Duration(days: 1)))) return false;
      return true;
    }).toList();
    final file = await PdfService.generateStatementPdf(
      businessName: 'حساباتي',
      contact: widget.contact,
      transactions: filtered,
    );
    if (!mounted) return;
    await ShareService.shareReceiptImage(context, file.path, 'تقرير معاملات: ${widget.contact.name}');
  }

  Future<void> _sendTransactions() async {
    final data = {
      'contact': {'name': widget.contact.name, 'phone': widget.contact.phone, 'type': widget.contact.type},
      'transactions': _txs.map((t) => {'amount': t.amount, 'type': t.type, 'note': t.note, 'date': t.date.toIso8601String(), 'balanceAfter': t.balanceAfter}).toList(),
    };
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.json');
    await f.writeAsString(jsonEncode(data));
    if (!mounted) return;
    await ShareService.shareReceiptImage(context, f.path, 'معاملات: ${widget.contact.name}');
  }

  Future<void> _importTransactions() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    final path = result?.files.single.path;
    if (path == null) return;
    try {
      final data = jsonDecode(await File(path).readAsString());
      final list = (data['transactions'] as List);
      final realm = await RealmService.realm;
      realm.write(() {
        for (final m in list) {
          realm.add(DebtTransaction(
            ObjectId(),
            widget.contact.id.toString(),
            (m['amount'] as num).toDouble(),
            m['type'],
            DateTime.parse(m['date']),
            (m['balanceAfter'] as num?)?.toDouble() ?? 0,
            'active',
            note: m['note'],
          ));
        }
      });
      await _recompute();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.transactionsImported} (${list.length})'), backgroundColor: AppTheme.incomeGreen));
    } catch (_) {}
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
              TextField(controller: amountC,
                      readOnly: true,
                      onTap: () => _openCalc(amountC), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount)),
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
      final path = await ReceiptImageService.generateReceiptImage(
        businessName: widget.contact.name,
        title: label,
        amount: t.amount,
        amountColor: t.type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen,
      );
      if (!mounted) return;
      await ShareService.shareReceiptImage(context, path, '$label ${t.amount.toStringAsFixed(2)} ج.م. — ${widget.contact.name}');
    }
  }

  Future<void> _addTx(String type) async {
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    String? _imgPath;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
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
            TextField(controller: amountC,
                      readOnly: true,
                      onTap: () => _openCalc(amountC), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx2, setS) => Column(
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
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imgPath!), height: 100, width: double.infinity, fit: BoxFit.cover)),
                  ],
                ],
              ),
            ),
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
                    DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute),
                    newBalance,
                    'active',
                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                    imagePath: _imgPath,
                  ));
                });
                if (ctx.mounted) Navigator.pop(ctx);
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


  Future<void> _openCalc(TextEditingController ctrl) async {
    final r = await CalculatorSheet.show(
      context,
      initial: double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0,
      title: 'المبلغ',
      currency: Cur.v,
    );
    if (r != null) {
      setState(() {
        ctrl.text = r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!widget.contact.isValid) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('تم حذف هذا السجل')));
    }
    final isCustomer = widget.contact.type == 'customer';
    final positive = _balance > 0;
    final color = isCustomer ? (positive ? AppTheme.incomeGreen : AppTheme.expenseRed) : (positive ? AppTheme.expenseRed : AppTheme.incomeGreen);
    final label = isCustomer ? l10n.owedToMe : l10n.owedByMe;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.contact.name, style: const TextStyle(fontSize: 18)),
            GestureDetector(
              onTap: () => setState(() => _showInfo = !_showInfo),
              child: Text(
                _showInfo ? '${widget.contact.phone ?? ''} ${widget.contact.address ?? ''}' : l10n.tapForContactInfo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble, color: Color(0xFF25D366)),
            tooltip: 'واتساب',
            onPressed: () async {
              final phone = widget.contact.phone ?? '';
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد رقم تليفون — عدّل بيانات العميل أولًا ✏️')));
                return;
              }
              var d = phone.replaceAll(RegExp(r'\D'), '');
              if (d.startsWith('0')) d = '20' + d.substring(1);
              await launchUrl(Uri.parse('https://wa.me/$d'), mode: LaunchMode.externalApplication);
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF2E7CF6)),
            tooltip: 'اتصال',
            onPressed: () async {
              final phone = widget.contact.phone ?? '';
              if (phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد رقم تليفون — عدّل بيانات العميل أولًا ✏️')));
                return;
              }
              final d = phone.replaceAll(RegExp(r'\D'), '');
              await launchUrl(Uri.parse('tel:+$d'), mode: LaunchMode.externalApplication);
            },
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareContact),
          IconButton(icon: const Icon(Icons.picture_as_pdf_outlined), onPressed: _exportPdf),
          IconButton(icon: const Icon(Icons.notifications_active_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScheduleReminderScreen(contact: widget.contact, currentBalance: _balance)))),
          PopupMenuButton<String>(
            onSelected: (v) { if (v == 'send') { _sendTransactions(); } else { _importTransactions(); } },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'send', child: Text(l10n.sendTransactions)),
              PopupMenuItem(value: 'import', child: Text(l10n.importTransactions)),
            ],
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${l10n.debtBook} (${_txs.length})', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
              ],
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
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(
                            amount: t.amount,
                            date: t.date,
                            note: t.note,
                            imagePath: t.imagePath,
                            color: c,
                            title: t.type == 'given' ? l10n.given : l10n.taken,
                            onEdit: () { Navigator.of(context).pop(); _manage(t); },
                            onDelete: () async {
                              Navigator.of(context).pop();
                              final realm = await RealmService.realm;
                              realm.write(() { t.status = 'deleted'; });
                              await _recompute();
                            },
                          ))),
                          onLongPress: () => _manage(t),
                          leading: Icon(t.type == 'given' ? Icons.arrow_upward : Icons.arrow_downward, color: c),
                          title: Text(t.type == 'given' ? l10n.given : l10n.taken),
                          subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}  ${t.note ?? ''}'),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.incomeGreen.withOpacity(0.8), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _addTx('taken'), child: Text(l10n.taken, style: const TextStyle(fontSize: 16)))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.expenseRed.withOpacity(0.8), padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => _addTx('given'), child: Text(l10n.given, style: const TextStyle(fontSize: 16)))),
            ],
          ),
        ),
      ),
    );
  }
}
