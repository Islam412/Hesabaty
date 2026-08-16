import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/widgets/qr_badge.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class PublicStatementScreen extends StatefulWidget {
  final String? contactId;
  final String header;
  const PublicStatementScreen({super.key, this.contactId, required this.header});
  @override
  State<PublicStatementScreen> createState() => _PublicStatementScreenState();
}

class _PublicStatementScreenState extends State<PublicStatementScreen> {
  bool _en = false;
  String L(String ar, String en) => _en ? en : ar;

  Future<List<_Tx>> _load() async {
    final r = await RealmService.realm;
    final list = <_Tx>[];
    if (widget.contactId != null) {
      for (final t in r.all<DebtTransaction>().where((t) => t.contactId == widget.contactId && t.status != 'deleted')) {
        list.add(_Tx(date: t.date, amount: t.amount, isIn: t.type == 'given', note: t.note));
      }
    } else {
      for (final t in r.all<CashTransaction>()) {
        list.add(_Tx(date: t.date, amount: t.amount, isIn: t.type.contains('in'), note: t.note));
      }
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L('كشف الحساب العام', 'Public Statement')),
        actions: [
          IconButton(icon: const Icon(Icons.language), tooltip: 'EN / AR', onPressed: () => setState(() => _en = !_en)),
        ],
      ),
      body: FutureBuilder<List<_Tx>>(
        future: _load(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final txs = snap.data!;
          double bal = 0, rec = 0, pay = 0;
          final rows = <Map<String, dynamic>>[];
          for (final t in txs) {
            bal += t.isIn ? t.amount : -t.amount;
            if (t.isIn) rec += t.amount; else pay += t.amount;
            rows.add({'t': t, 'after': bal});
          }
          final desc = rows.reversed.toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(child: Text(widget.header, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              const SizedBox(height: 4),
              Center(child: Text(L('الرصيد العام', 'General balance'), style: TextStyle(color: Colors.grey.shade600))),
              const SizedBox(height: 4),
              Center(child: Text(bal.toStringAsFixed(2), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: bal >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed))),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _sum(L('إجمالي المقبوض', 'Total received'), rec, AppTheme.incomeGreen)),
                const SizedBox(width: 10),
                Expanded(child: _sum(L('إجمالي المدفوع', 'Total paid'), pay, AppTheme.expenseRed)),
              ]),
              const SizedBox(height: 16),
              Text(L('سجل العمليات (${txs.length})', 'Transaction history (${txs.length})'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...desc.map((r) {
                final t = r['t'] as _Tx;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: (t.isIn ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.15), child: Icon(t.isIn ? Icons.arrow_downward : Icons.arrow_upward, color: t.isIn ? AppTheme.incomeGreen : AppTheme.expenseRed)),
                    title: Text(DateFormat('yyyy/MM/dd  hh:mm a').format(t.date)),
                    subtitle: Text('${L('الرصيد بعدها', 'Balance after')}: ${(r['after'] as double).toStringAsFixed(2)}'),
                    trailing: Text(t.amount.toStringAsFixed(2), style: TextStyle(color: t.isIn ? AppTheme.incomeGreen : AppTheme.expenseRed, fontWeight: FontWeight.w800)),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Center(child: QrBadge(data: 'https://hesabaty.app/r/${widget.contactId ?? 'cash'}', size: 140)),
              const SizedBox(height: 8),
              Center(child: OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://hesabaty.app/r/${widget.contactId ?? 'cash'}'), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new),
                label: Text(L('فتح الصفحة في المتصفح', 'Open page in browser')),
              )),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _sum(String label, double v, Color c) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(v.toStringAsFixed(2), style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _Tx {
  final DateTime date;
  final double amount;
  final bool isIn;
  final String? note;
  _Tx({required this.date, required this.amount, required this.isIn, this.note});
}
