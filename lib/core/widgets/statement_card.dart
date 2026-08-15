import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../../core/services/account_service.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class ContactStatementCard extends StatelessWidget {
  final Contact contact;
  const ContactStatementCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DebtTransaction>>(
      future: RealmService.realm.then((r) => r.all<DebtTransaction>().toList()
        ..removeWhere((t) => t.contactId != contact.id.toString() || t.status == 'deleted')
        ..sort((a, b) => b.date.compareTo(a.date))),
      builder: (ctx, snap) {
        final txs = snap.data ?? [];
        double b = 0;
        double totalReceived = 0, totalPaid = 0;
        for (final t in txs) {
          if (t.type == 'given') { b += t.amount; totalReceived += t.amount; }
          else { b -= t.amount; totalPaid += t.amount; }
        }
        final isCustomer = contact.type == 'customer';
        final owedToMe = b < 0 ? -b : 0.0;
        final owedOnMe = b > 0 ? b : 0.0;
        return FutureBuilder<String>(
          future: _ownerLine(),
          builder: (ctx2, ownerSnap) {
            return Container(
              width: 720,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2F7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD7E0EC)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('حساباتي', style: TextStyle(color: Color(0xFF7EA6D9), fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('كشف حساب معاملة', style: TextStyle(color: Color(0xFF5A7184), fontSize: 13)),
                  const SizedBox(height: 18),
                  // ===== المرسل والمرسل إليه =====
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('من', style: TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(ownerSnap.data ?? 'حساباتي', style: const TextStyle(color: Color(0xFF16324F), fontSize: 15, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward, color: Color(0xFF2E7CF6)),
                        Expanded(
                          child: Column(
                            children: [
                              Text(isCustomer ? 'إلى (عميل)' : 'إلى (مورد)', style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(contact.name, style: const TextStyle(color: Color(0xFF16324F), fontSize: 15, fontWeight: FontWeight.w800)),
                              if ((contact.phone ?? '').isNotEmpty)
                                Text(contact.phone!, style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 11), textDirection: TextDirection.ltr),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ===== الأرصدة =====
                  Row(
                    children: [
                      Expanded(child: _box('مستحق لي', owedToMe, AppTheme.incomeGreen)),
                      const SizedBox(width: 10),
                      Expanded(child: _box('مستحق عليّ', owedOnMe, AppTheme.expenseRed)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _box('إجمالي المقبوض', totalReceived, AppTheme.incomeGreen)),
                      const SizedBox(width: 10),
                      Expanded(child: _box('إجمالي المدفوع', totalPaid, AppTheme.expenseRed)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('عدد العمليات: ${txs.length}', style: const TextStyle(color: Color(0xFF5A7184), fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  // ===== كل العمليات =====
                  ...txs.map((t) {
                    final received = t.type == 'given';
                    final img = t.imagePath ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: (received ? AppTheme.incomeGreen : AppTheme.expenseRed).withOpacity(0.15),
                                child: Icon(received ? Icons.arrow_downward : Icons.arrow_upward, color: received ? AppTheme.incomeGreen : AppTheme.expenseRed, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(received ? 'مقبوض' : 'مدفوع', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF16324F))),
                                    const SizedBox(height: 3),
                                    Text(DateFormat('yyyy/MM/dd  hh:mm a').format(t.date), style: const TextStyle(color: Color(0xFF5A7184), fontSize: 12)),
                                    if ((t.note ?? '').isNotEmpty)
                                      Text('📝 ${t.note}', style: const TextStyle(color: Color(0xFF8AA0B2), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text('${t.amount.toStringAsFixed(2)}', style: TextStyle(color: received ? AppTheme.incomeGreen : AppTheme.expenseRed, fontSize: 18, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
                            ],
                          ),
                          if (img.isNotEmpty && File(img).existsSync()) ...[
                            const SizedBox(height: 10),
                            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(img), height: 140, width: double.infinity, fit: BoxFit.cover)),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  const Text('حساباتي', style: TextStyle(color: Color(0xFF2E7CF6), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String> _ownerLine() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString('profile_name') ?? '';
    final phone = await AccountService.sessionPhone() ?? '';
    if (name.isNotEmpty) return phone.isNotEmpty ? '$name — $phone' : name;
    return phone.isNotEmpty ? 'حساباتي — $phone' : 'حساباتي';
  }

  Widget _box(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(2), style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900), textDirection: TextDirection.ltr),
        ],
      ),
    );
  }
}
