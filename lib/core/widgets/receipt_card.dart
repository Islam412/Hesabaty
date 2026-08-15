import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class ReceiptCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final DateTime date;
  final String? note;
  final Color color;
  const ReceiptCard({super.key, required this.title, required this.amount, required this.currency, required this.date, this.note, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 640,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E0EC)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('حساباتي', style: TextStyle(color: Color(0xFF7EA6D9), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 26),
          Text(title, style: const TextStyle(color: Color(0xFF16324F), fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Text('${amount.toStringAsFixed(2)} $currency', style: TextStyle(color: color, fontSize: 44, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
          const SizedBox(height: 22),
          _pill('🕐  ${DateFormat('yyyy/MM/dd  hh:mm a').format(date)}'),
          if ((note ?? '').isNotEmpty) ...[const SizedBox(height: 12), _pill('📝  $note')],
          const SizedBox(height: 30),
          const Text('حساباتي', style: TextStyle(color: Color(0xFF2E7CF6), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Color(0xFF5A7184), fontSize: 16, fontWeight: FontWeight.w600)),
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
          if (t.type.contains('in')) income += t.amount;
          else expense += t.amount;
        }
        return Container(
          width: 700,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD7E0EC)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('حساباتي', style: TextStyle(color: Color(0xFF7EA6D9), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text('دفتر النقدية — كل المعاملات', style: TextStyle(color: Color(0xFF16324F), fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('عدد المعاملات: ${list.length}', style: const TextStyle(color: Color(0xFF5A7184), fontSize: 14)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _totalBox('إجمالي الدخل', income, AppTheme.incomeGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _totalBox('إجمالي المصروف', expense, AppTheme.expenseRed)),
                ],
              ),
              const SizedBox(height: 8),
              _totalBox('الصافي', income - expense, (income - expense) >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
              const SizedBox(height: 20),
              ...list.map((t) {
                final isIn = t.type.contains('in');
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: (isIn ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.15), child: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, color: isIn ? AppTheme.incomeGreen : AppTheme.expenseRed, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isIn ? 'دخل' : 'مصروف', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF16324F))),
                            const SizedBox(height: 3),
                            Text(DateFormat('yyyy/MM/dd  hh:mm a').format(t.date), style: const TextStyle(color: Color(0xFF5A7184), fontSize: 12)),
                            if ((t.note ?? '').isNotEmpty) Text('📝 ${t.note}', style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('${t.amount.toStringAsFixed(2)} ${Cur.v}', style: TextStyle(color: isIn ? AppTheme.incomeGreen : AppTheme.expenseRed, fontSize: 18, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
                    ],
                  ),
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
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${value.toStringAsFixed(2)} ${Cur.v}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
        ],
      ),
    );
  }
}
