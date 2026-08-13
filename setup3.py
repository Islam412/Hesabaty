import os, json

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

en = {"@@locale":"en","appName":"Capital & Debt Ledger","more":"More","cashBook":"Cash Book","debtBook":"Debt Book","income":"Income","expense":"Expense","balance":"Balance","customers":"Customers","suppliers":"Suppliers","emptyCashBook":"Here you can record all your daily expenses and income.","emptyDebtBook":"Here you can record all customer and supplier debts.","shareApp":"Share the app with merchants","myBusinessWallet":"My Business Wallet","walletDesc":"Receive your money instantly, securely, from anywhere","paymentServices":"Electronic Payment Services","paymentDesc":"Offer bill payments and top-ups for your customers and earn commissions","businessCard":"Business Card","inventoryStaff":"Inventory & Staff","settings":"Settings","autoBackup":"Auto Backup","contactUs":"Contact Us","aboutApp":"About the App","addCustomer":"Add Customer","addSupplier":"Add Supplier","importContacts":"Import customer numbers","importContactsDesc":"Sharing phone numbers with the app lets you add new customers quickly.","contactsDenied":"You have disabled access permission to contacts","name":"Name","phoneNumber":"Phone number","address":"Address","tags":"Tags","addTags":"Add tags","tagsDesc":"Use custom tags (e.g. VIP, wholesale, region) to group and filter your contacts quickly","confirm":"Confirm","cancel":"Cancel","owedToMe":"Owed to me","owedByMe":"Owed by me","given":"Given","taken":"Taken","save":"Save","amount":"Amount","note":"Note","search":"Search","version":"Version"}

ar = {"@@locale":"ar","appName":"دفتر رأس المال والديون","more":"المزيد","cashBook":"دفتر النقدية","debtBook":"دفتر الديون","income":"دخل","expense":"مصروف","balance":"الرصيد","customers":"العملاء","suppliers":"الموردون","emptyCashBook":"هنا يمكنك تسجيل جميع المصروفات والمداخيل اليومية","emptyDebtBook":"هنا يمكنك تسجيل جميع ديون العملاء والموردين.","shareApp":"شارك التطبيق مع التجار","myBusinessWallet":"محفظتي التجارية","walletDesc":"توصل بفلوسك على الفور بكل أمان ومن أي مكان","paymentServices":"خدمات الدفع الالكتروني","paymentDesc":"قدم خدمات دفع الفواتير وشحن الرصيد لعملائك واربح عمولات","businessCard":"بطاقة العمل","inventoryStaff":"المخزون والموظفون","settings":"إعدادات","autoBackup":"نسخ تلقائي","contactUs":"إتصل بنا","aboutApp":"حول التطبيق","addCustomer":"إضافة عميل","addSupplier":"إضافة مورد","importContacts":"استيراد ارقام العملاء","importContactsDesc":"مشاركة أرقام الهاتف مع التطبيق تمكنك من إضافة عملاء جدد بسرعة.","contactsDenied":"لقد قمت بتعطيل إذن الدخول لجهات الاتصال","name":"الاسم","phoneNumber":"رقم الهاتف","address":"العنوان","tags":"التصنيفات","addTags":"إضافة تصنيفات","tagsDesc":"استخدم تصنيفات مخصصة (مثل VIP، جملة، المنطقة) لتصنيف جهات الاتصال الخاصة بك للتجميع والتصفية بسرعة","confirm":"تأكيد","cancel":"إلغاء","owedToMe":"مستحق لي","owedByMe":"مستحق عليّ","given":"مدفوع","taken":"مقبوض","save":"حفظ","amount":"المبلغ","note":"ملاحظة","search":"بحث","version":"الإصدار"}

w('lib/l10n/app_en.arb', json.dumps(en, ensure_ascii=False, indent=2))
w('lib/l10n/app_ar.arb', json.dumps(ar, ensure_ascii=False, indent=2))

w('lib/features/screens.dart', """export 'more/more_screen.dart';
export 'cash_book/cash_book_screen.dart';
export 'debt_book/debt_book_screen.dart';
""")

w('lib/features/more/more_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import '../../app/theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget _bigCard(String title, String subtitle, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 44, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, {Widget? extra}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
            child: Icon(icon, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
          if (extra != null) ...[extra, const SizedBox(width: 8)],
          Icon(Icons.chevron_left, color: AppTheme.primaryBlue, size: 28),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Row(
              children: [
                Text(l10n.more, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.shareApp, style: TextStyle(color: Colors.grey.shade500))),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                  child: Icon(Icons.share, color: AppTheme.primaryBlue),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _bigCard(l10n.myBusinessWallet, l10n.walletDesc, Icons.account_balance_wallet),
            const SizedBox(height: 14),
            _bigCard(l10n.paymentServices, l10n.paymentDesc, Icons.point_of_sale),
            const SizedBox(height: 18),
            _row(Icons.work_outline, l10n.businessCard),
            _row(Icons.grid_view_outlined, l10n.inventoryStaff),
            _row(Icons.settings_outlined, l10n.settings),
            _row(Icons.backup_outlined, l10n.autoBackup, extra: Icon(Icons.cloud_done, color: AppTheme.incomeGreen, size: 20)),
            _row(Icons.chat_bubble_outline, l10n.contactUs, extra: CircleAvatar(radius: 12, backgroundColor: AppTheme.primaryBlue.withOpacity(0.15), child: Text('0', style: TextStyle(fontSize: 11, color: AppTheme.primaryBlue)))),
            const SizedBox(height: 26),
            Center(child: Text(l10n.aboutApp, style: TextStyle(color: Colors.grey.shade400))),
            const SizedBox(height: 4),
            Center(child: Text(l10n.version + ' 1.0.0', style: TextStyle(color: Colors.grey.shade400))),
          ],
        ),
      ),
    );
  }
}
""")

w('lib/features/cash_book/cash_book_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

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

  Future<void> _add(String type) async {
    final amountC = TextEditingController();
    final noteC = TextEditingController();
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
            TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed, minWidth: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16)),
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
                    DateTime.now(),
                    newBalance,
                    'active',
                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
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
          FloatingActionButton.extended(backgroundColor: AppTheme.incomeGreen, onPressed: () => _add('income'), label: Text('+ ${l10n.income}')),
          const SizedBox(width: 12),
          FloatingActionButton.extended(backgroundColor: AppTheme.expenseRed, onPressed: () => _add('expense'), label: Text('- ${l10n.expense}')),
        ],
      ),
    );
  }
}
""")

w('lib/features/debt_book/add_contact_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class AddContactScreen extends StatefulWidget {
  final bool isSupplier;
  const AddContactScreen({super.key, this.isSupplier = false});
  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final List<String> _tags = [];

  Future<void> _addTag() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final value = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addTags),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: Text(l10n.confirm)),
        ],
      ),
    );
    if (value != null && value.isNotEmpty) setState(() => _tags.add(value));
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final realm = await RealmService.realm;
    realm.write(() {
      realm.add(Contact(
        ObjectId(),
        'business_1',
        _name.text.trim(),
        widget.isSupplier ? 'supplier' : 'customer',
        _tags,
        DateTime.now(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      ));
    });
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    return Scaffold(
      appBar: AppBar(title: Text(widget.isSupplier ? l10n.addSupplier : l10n.addCustomer)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.name, style: label),
          const SizedBox(height: 8),
          TextField(controller: _name, decoration: InputDecoration(hintText: l10n.name, border: border)),
          const SizedBox(height: 16),
          Text(l10n.phoneNumber, style: label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: l10n.phoneNumber, border: border))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('+20', style: TextStyle(fontWeight: FontWeight.bold)), Text(' 🇪🇬')]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l10n.address, style: label),
          const SizedBox(height: 8),
          TextField(controller: _address, decoration: InputDecoration(hintText: l10n.address, border: border, suffixIcon: Icon(Icons.chevron_left, color: AppTheme.primaryBlue))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.tags, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                    ActionChip(
                      avatar: Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryBlue),
                      label: Text(l10n.addTags, style: TextStyle(color: AppTheme.primaryBlue)),
                      onPressed: _addTag,
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: _tags.map((t) => Chip(label: Text(t), onDeleted: () => setState(() => _tags.remove(t)))).toList()),
                ],
                const SizedBox(height: 8),
                Text(l10n.tagsDesc, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: _save,
            child: Text(l10n.confirm, style: const TextStyle(fontSize: 17)),
          ),
        ),
      ),
    );
  }
}
""")

w('lib/features/debt_book/contact_details_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

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
            TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen, minWidth: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16)),
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
          IconButton(icon: const Icon(Icons.message_outlined), onPressed: () {}),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(backgroundColor: AppTheme.expenseRed, onPressed: () => _addTx('given'), label: Text(l10n.given)),
          const SizedBox(width: 12),
          FloatingActionButton.extended(backgroundColor: AppTheme.incomeGreen, onPressed: () => _addTx('taken'), label: Text(l10n.taken)),
        ],
      ),
    );
  }
}
""")

w('lib/features/debt_book/debt_book_screen.dart', """import 'package:flutter/material.dart';
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
    double owedToMe = 0;
    double owedByMe = 0;
    for (final c in all) {
      final cid = c.id.toString();
      double b = 0;
      for (final t in txs) {
        if (t.contactId != cid) continue;
        final sign = c.type == 'customer' ? (t.type == 'given' ? 1.0 : -1.0) : (t.type == 'taken' ? 1.0 : -1.0);
        b += t.amount * sign;
      }
      balances[cid] = b;
      if (c.type == 'customer' && b > 0) owedToMe += b;
      if (c.type == 'supplier' && b > 0) owedByMe += b;
    }
    if (!mounted) return;
    setState(() {
      _balances = balances;
      _customers = all.where((c) => c.type == 'customer').toList();
      _suppliers = all.where((c) => c.type == 'supplier').toList();
      _owedToMe = owedToMe;
      _owedByMe = owedByMe;
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCustomers = _tab.index == 0;
    final list = (isCustomers ? _customers : _suppliers).where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.debtBook),
        bottom: TabBar(controller: _tab, tabs: [Tab(text: l10n.customers), Tab(text: l10n.suppliers)]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _summaryCard(l10n.owedToMe, _owedToMe, AppTheme.incomeGreen)),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard(l10n.owedByMe, _owedByMe, AppTheme.expenseRed)),
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
                      final color = c.type == 'customer' ? (positive ? AppTheme.incomeGreen : AppTheme.expenseRed) : (positive ? AppTheme.expenseRed : AppTheme.incomeGreen);
                      final label = c.type == 'customer' ? l10n.owedToMe : l10n.owedByMe;
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
                          subtitle: Text(label, style: TextStyle(color: color, fontSize: 12)),
                          trailing: Text(bal.abs().toStringAsFixed(2), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddContactScreen(isSupplier: !isCustomers)));
          if (result == true) _load();
        },
        label: Text(isCustomers ? l10n.addCustomer : l10n.addSupplier),
        icon: const Icon(Icons.person_add_alt),
      ),
    );
  }
}
""")

print("✅ All app screens created successfully!")
