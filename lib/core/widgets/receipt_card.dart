import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/services/realm_service.dart';
import '../../data/models/app_models.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/account_service.dart';
import '../../app/theme.dart';
import '../../core/services/account_service.dart';
import 'qr_badge.dart';

class ReceiptCard extends StatefulWidget {
  final String title;
  final double amount;
  final String currency;
  final DateTime date;
  final String? note;
  final Color color;
  final String? recipientName;
  final String? recipientPhone;
  final String? token;
  final String? imagePath;
  final String? contactId;
  final bool interactive;
  final VoidCallback? onOpenStatement;
  const ReceiptCard({
    super.key,
    required this.title, required this.amount, required this.currency,
    required this.date, this.note, required this.color,
    this.recipientName, this.recipientPhone, this.token,
    this.imagePath,
    this.contactId,
    this.interactive = false,
    this.onOpenStatement,
  });
  @override
  State<ReceiptCard> createState() => _ReceiptCardState();
}

class _ReceiptCardState extends State<ReceiptCard> {
  String _ownerLine = '';
  double? _owedToMe;
  double? _owedOnMe;
  String _ownerPhone = '';
  @override
  void initState() { super.initState(); _load();
    if (widget.contactId != null) _loadBalance(); }
  Future<void> _loadBalance() async {
    try {
      final r = await RealmService.realm;
      final txs = r.all<DebtTransaction>().where((t) => t.contactId == widget.contactId && t.status != 'deleted').toList();
      double b = 0;
      for (final t in txs) {
        b += t.type == 'given' ? t.amount : -t.amount;
      }
      if (mounted) setState(() { _owedToMe = b < 0 ? -b : 0; _owedOnMe = b > 0 ? b : 0; });
    } catch (_) {}
  }

  Future<void> _load() async {
    final p = await AccPrefs.scoped();
    final name = p.getString('profile_name') ?? '';
    final phone = await AccountService.sessionPhone() ?? '';
    setState(() {
      _ownerLine = name.isNotEmpty ? name : 'حساباتي';
      _ownerPhone = phone;
    });
  }

  String get _shareUrl {
    final t = widget.token ?? DateTime.now().millisecondsSinceEpoch.toString();
    return 'https://hesabaty.app/r/$t';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 680,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E0EC)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('حساباتي', style: TextStyle(color: Color(0xFF7EA6D9), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(widget.title, style: const TextStyle(color: Color(0xFF16324F), fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Text('${widget.amount.toStringAsFixed(2)} ${widget.currency}',
              style: TextStyle(color: widget.color, fontSize: 44, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(child: Column(children: [
                  const Text('من', style: TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(_ownerLine, style: const TextStyle(color: Color(0xFF16324F), fontSize: 14, fontWeight: FontWeight.w800)),
                  if (_ownerPhone.isNotEmpty) Text(_ownerPhone, style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 11), textDirection: TextDirection.ltr),
                ])),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2E7CF6).withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward, color: Color(0xFF2E7CF6), size: 18)),
                Expanded(child: Column(children: [
                  const Text('إلى', style: TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(widget.recipientName ?? '—', style: const TextStyle(color: Color(0xFF16324F), fontSize: 14, fontWeight: FontWeight.w800)),
                  if ((widget.recipientPhone ?? '').isNotEmpty) Text(widget.recipientPhone!, style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 11), textDirection: TextDirection.ltr),
                ])),
              ],
            ),
          ),
          if (_owedToMe != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _balBox('مستحق لي', _owedToMe!, AppTheme.incomeGreen)),
              const SizedBox(width: 10),
              Expanded(child: _balBox('مستحق عليّ', _owedOnMe!, AppTheme.expenseRed)),
            ]),
          ],
          const SizedBox(height: 16),
          _pill('🕐  ${DateFormat("yyyy/MM/dd  hh:mm a").format(widget.date)}'),
          const SizedBox(height: 8),
          _pill('📝  ${widget.note != null && widget.note!.isNotEmpty ? widget.note : 'بدون ملاحظة'}'),
          if (widget.imagePath != null && widget.imagePath!.isNotEmpty && File(widget.imagePath!).existsSync()) ...[
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(widget.imagePath!), height: 160, width: double.infinity, fit: BoxFit.cover)),
          ],
          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (widget.interactive && widget.onOpenStatement != null) ? widget.onOpenStatement : null,
            child: Row(
            children: [
              QrBadge(data: _shareUrl, size: 90),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('عرض كل المعاملات عبر الرابط', style: TextStyle(color: Color(0xFF8AA0B2), fontSize: 11)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text(_shareUrl, style: const TextStyle(color: Color(0xFF2E7CF6), fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace'), textDirection: TextDirection.ltr)),
                const SizedBox(height: 6),
                const Text('امسح الكود أو افتح الرابط لرؤية الرصيد وسجل العمليات كاملاً', style: TextStyle(color: Color(0xFF8AA0B2), fontSize: 10)),
              ])),
            ],
          ),
          ),
          const SizedBox(height: 20),
          const Text('حساباتي', style: TextStyle(color: Color(0xFF2E7CF6), fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _balBox(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${value.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
      ]),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Color(0xFF5A7184), fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }
}


class CashAllCard extends StatelessWidget {
  const CashAllCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CashTransaction>>(
      future: RealmService.realm.then((r) => r.all<CashTransaction>().toList()..sort((a, b) => b.date.compareTo(a.date))),
      builder: (ctx, snap) {
        final list = snap.data ?? [];
        double income = 0, expense = 0;
        for (final t in list) {
          if (t.type.contains('in')) income += t.amount; else expense += t.amount;
        }
        return Container(
          width: 700,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: const Color(0xFFEEF2F7), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFD7E0EC))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('حساباتي', style: TextStyle(color: Color(0xFF7EA6D9), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text('دفتر النقدية — كل المعاملات', style: TextStyle(color: Color(0xFF16324F), fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('عدد المعاملات: ${list.length}', style: const TextStyle(color: Color(0xFF5A7184), fontSize: 14)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _totalBox('إجمالي الدخل', income, AppTheme.incomeGreen)),
                const SizedBox(width: 12),
                Expanded(child: _totalBox('إجمالي المصروف', expense, AppTheme.expenseRed)),
              ]),
              const SizedBox(height: 8),
              _totalBox('الصافي', income - expense, (income - expense) >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
              const SizedBox(height: 20),
              ...list.map((t) {
                final isIn = t.type.contains('in');
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: (isIn ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.15), child: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, color: isIn ? AppTheme.incomeGreen : AppTheme.expenseRed, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(isIn ? 'دخل' : 'مصروف', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF16324F))),
                      const SizedBox(height: 3),
                      Text(DateFormat("yyyy/MM/dd  hh:mm a").format(t.date), style: const TextStyle(color: Color(0xFF5A7184), fontSize: 12)),
                      if ((t.note ?? '').isNotEmpty) Text('📝 ${t.note}', style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                    ])),
                    Text('${t.amount.toStringAsFixed(2)} ${Cur.v}', style: TextStyle(color: isIn ? AppTheme.incomeGreen : AppTheme.expenseRed, fontSize: 18, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
                  ]),
                );
              }),
              const SizedBox(height: 16),
              const Text('حساباتي', style: TextStyle(color: Color(0xFF2E7CF6), fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _totalBox(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(value.toStringAsFixed(2), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
      ]),
    );
  }
}
