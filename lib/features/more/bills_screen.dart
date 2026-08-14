import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';
import '../../core/services/bill_payment_service.dart';
import '../../core/services/wallet_service.dart';
import '../../data/models/app_models.dart';
import '../wallet/receipt_screen.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<LinkedCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await WalletService.getCards();
    if (!mounted) return;
    setState(() => _cards = cards);
  }

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'mobile', 'label': 'شحن الموبايل', 'icon': Icons.phone_android,
      'color': Color(0xFF2E7CF6),
      'providers': [
        {'id': 'vodafone', 'label': 'فودافون', 'icon': '🔴'},
        {'id': 'orange', 'label': 'اورنج', 'icon': '🟠'},
        {'id': 'etisalat', 'label': 'اتصالات', 'icon': '🟢'},
        {'id': 'we', 'label': 'WE', 'icon': '🟣'},
      ],
    },
    {
      'id': 'internet', 'label': 'الإنترنت', 'icon': Icons.wifi,
      'color': Color(0xFF00BCD4),
      'providers': [
        {'id': 'we', 'label': 'WE', 'icon': '🟣'},
        {'id': 'orange', 'label': 'اورنج', 'icon': '🟠'},
        {'id': 'vodafone', 'label': 'فودافون', 'icon': '🔴'},
        {'id': 'etisalat', 'label': 'اتصالات', 'icon': '🟢'},
      ],
    },
    {
      'id': 'electricity', 'label': 'الكهرباء', 'icon': Icons.bolt,
      'color': Color(0xFFFFC107),
      'providers': [
        {'id': 'cairo', 'label': 'القاهرة الكبرى', 'icon': '⚡'},
        {'id': 'alex', 'label': 'الإسكندرية', 'icon': '⚡'},
        {'id': 'delta', 'label': 'الدلتا', 'icon': '⚡'},
        {'id': 'canal', 'label': 'قناة السويس', 'icon': '⚡'},
        {'id': 'middle', 'label': 'وسط القاهرة', 'icon': '⚡'},
        {'id': 'north', 'label': 'شمال القاهرة', 'icon': '⚡'},
        {'id': 'beheira', 'label': 'البحيرة', 'icon': '⚡'},
      ],
    },
    {
      'id': 'gas', 'label': 'الغاز', 'icon': Icons.local_fire_department,
      'color': Color(0xFFFF5722),
      'providers': [
        {'id': 'towngas', 'label': 'تاون جاس', 'icon': '🔥'},
        {'id': 'natgas', 'label': 'نات جاس', 'icon': '🔥'},
        {'id': 'sigas', 'label': 'سي جاس', 'icon': '🔥'},
        {'id': 'hipco', 'label': 'هيبكو', 'icon': '🔥'},
      ],
    },
    {
      'id': 'water', 'label': 'المياه', 'icon': Icons.water_drop,
      'color': Color(0xFF0288D1),
      'providers': [
        {'id': 'cairo', 'label': 'مياه القاهرة', 'icon': '💧'},
        {'id': 'alex', 'label': 'مياه الإسكندرية', 'icon': '💧'},
        {'id': 'giza', 'label': 'مياه الجيزة', 'icon': '💧'},
        {'id': 'canal', 'label': 'مياه القناة', 'icon': '💧'},
      ],
    },
    {
      'id': 'landline', 'label': 'التليفون الأرضي', 'icon': Icons.phone,
      'color': Color(0xFF795548),
      'providers': [
        {'id': 'we', 'label': 'WE', 'icon': '🟣'},
      ],
    },
    {
      'id': 'tv', 'label': 'التلفزيون', 'icon': Icons.tv,
      'color': Color(0xFF9C27B0),
      'providers': [
        {'id': 'dstv', 'label': 'بي إن سبورت', 'icon': '📺'},
        {'id': 'osn', 'label': 'OSN', 'icon': '📺'},
      ],
    },
    {
      'id': 'donations', 'label': 'التبرعات', 'icon': Icons.volunteer_activism,
      'color': Color(0xFFE91E63),
      'providers': [
        {'id': '57357', 'label': 'مستشفى 57357', 'icon': '❤️'},
        {'id': 'resala', 'label': 'رسالة', 'icon': '❤️'},
        {'id': 'orphan', 'label': 'كافل اليتيم', 'icon': '❤️'},
      ],
    },
    {
      'id': 'government', 'label': 'خدمات حكومية', 'icon': Icons.account_balance,
      'color': Color(0xFF607D8B),
      'providers': [
        {'id': 'traffic', 'label': 'مخالفات المرور', 'icon': '🚗'},
        {'id': 'real_estate', 'label': 'الضريبة العقارية', 'icon': '🏠'},
      ],
    },
  ];

  void _openPayment(Map<String, dynamic> category, Map<String, dynamic> provider) async {
    final l10n = AppLocalizations.of(context)!;
    if (_cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.addCard), backgroundColor: AppTheme.expenseRed));
      return;
    }
    final accountCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final card = _cards.first;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(category['icon'] as IconData, color: category['color'] as Color, size: 28),
                const SizedBox(width: 8),
                Text('${provider['label']} - ${category['label']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: accountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'رقم الحساب/الفاتورة/الخط',
                border: const OutlineInputBorder(),
                hintText: _getHint(category['id'] as String),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'المبلغ',
                suffixText: 'ج.م',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: category['color'] as Color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () async {
                final account = accountCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (account.isEmpty || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتب رقم الحساب والمبلغ')));
                  return;
                }
                Navigator.pop(ctx);
                await _processPayment(category, provider, account, amount, card);
              },
              child: const Text('ادفع دلوقتي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getHint(String categoryId) {
    switch (categoryId) {
      case 'mobile': return 'رقم الموبايل (مثال: 01012345678)';
      case 'internet': return 'رقم اشتراك النت';
      case 'electricity': return 'رقم عداد الكهرباء';
      case 'gas': return 'رقم عداد الغاز';
      case 'water': return 'رقم عداد المياه';
      case 'landline': return 'رقم التليفون الأرضي';
      case 'tv': return 'رقم الاشتراك';
      default: return 'رقم الحساب';
    }
  }

  Future<void> _processPayment(Map<String, dynamic> category, Map<String, dynamic> provider, String account, double amount, LinkedCard card) async {
    final result = await BillPaymentService.pay(
      categoryId: category['id'] as String,
      categoryLabel: category['label'] as String,
      providerId: provider['id'] as String,
      providerLabel: provider['label'] as String,
      account: account,
      amount: amount,
      fromCard: card,
    );
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ReceiptScreen(
      success: result.success,
      amount: amount,
      destination: '${provider['label']} - $account',
      destinationLabel: category['label'] as String,
      reference: result.reference ?? '',
      error: result.error,
      type: 'bill',
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفع الفواتير والشحن')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final c = _categories[i];
          final color = c['color'] as Color;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Theme(
              data: ThemeData(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(c['icon'] as IconData, color: color, size: 28),
                ),
                title: Text(c['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text('${(c['providers'] as List).length} خدمة متاحة'),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (c['providers'] as List).map((p) => OutlinedButton.icon(
                      onPressed: () => _openPayment(c, p),
                      icon: Text(p['icon'] as String, style: const TextStyle(fontSize: 18)),
                      label: Text(p['label'] as String),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
