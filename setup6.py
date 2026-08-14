import os, json

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

for path, extra in [
    ('lib/l10n/app_en.arb', {"txSuccess":"Transaction completed successfully","finish":"Done","backupSection":"Backup","autoBackupLabel":"Daily automatic backup","exportShare":"Export & share now","restore":"Restore from backup","lastBackupAt":"Last backup","noBackup":"No backup yet","restoreDone":"Backup restored successfully"}),
    ('lib/l10n/app_ar.arb', {"txSuccess":"تمت المعاملة بنجاح","finish":"انهاء","backupSection":"النسخ الاحتياطي","autoBackupLabel":"نسخ احتياطي تلقائي يومي","exportShare":"تصدير ومشاركة الآن","restore":"استعادة من نسخة","lastBackupAt":"آخر نسخة","noBackup":"لا توجد نسخة بعد","restoreDone":"تمت الاستعادة بنجاح"}),
]:
    d = json.load(open(path, encoding='utf-8'))
    d.update(extra)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(d, f, ensure_ascii=False, indent=2)

w('lib/features/shared/amount_calculator_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';

class AmountCalculatorScreen extends StatefulWidget {
  final String title;
  final Color color;
  const AmountCalculatorScreen({super.key, required this.title, required this.color});

  @override
  State<AmountCalculatorScreen> createState() => _AmountCalculatorScreenState();
}

class _AmountCalculatorScreenState extends State<AmountCalculatorScreen> {
  String _expr = '';
  double _mem = 0;

  List<String> _tokenize(String e) {
    final tokens = <String>[];
    String num = '';
    for (int i = 0; i < e.length; i++) {
      final ch = e[i];
      if (RegExp('[0-9.]').hasMatch(ch)) {
        num += ch;
      } else {
        if (num.isNotEmpty) { tokens.add(num); num = ''; }
        tokens.add(ch);
      }
    }
    if (num.isNotEmpty) tokens.add(num);
    return tokens;
  }

  double _eval(String e) {
    final t = _tokenize(e);
    if (t.isEmpty) return 0;
    final vals = <double>[double.tryParse(t[0]) ?? 0];
    final ops = <String>[];
    for (int i = 1; i + 1 < t.length; i += 2) {
      final op = t[i];
      final v = double.tryParse(t[i + 1]) ?? 0;
      if (op == '*' || op == '/') {
        final last = vals.removeLast();
        vals.add(op == '*' ? last * v : (v == 0 ? 0 : last / v));
      } else {
        ops.add(op);
        vals.add(v);
      }
    }
    double total = vals[0];
    for (int k = 0; k < ops.length; k++) {
      total = ops[k] == '+' ? total + vals[k + 1] : total - vals[k + 1];
    }
    return total;
  }

  String _display(String e) => e.replaceAll('*', '×').replaceAll('/', '÷').replaceAll('-', '−');

  String _trim(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void _press(String key) {
    setState(() {
      if (key == 'AC') { _expr = ''; return; }
      if (key == 'DEL') { if (_expr.isNotEmpty) _expr = _expr.substring(0, _expr.length - 1); return; }
      if (key == '=') { _expr = _trim(_eval(_expr)); return; }
      if (key == '%') { _expr = _trim(_eval(_expr) / 100); return; }
      if (key == 'M+') { _mem += _eval(_expr); _expr = ''; return; }
      if (key == 'M-') { _mem -= _eval(_expr); _expr = ''; return; }
      if (key == 'MR') { _expr += _trim(_mem); return; }
      const ops = ['+', '-', '*', '/'];
      if (ops.contains(key)) {
        if (_expr.isEmpty) { if (key == '-') { _expr = '-'; } return; }
        final lastCh = _expr[_expr.length - 1];
        if (ops.contains(lastCh)) { _expr = _expr.substring(0, _expr.length - 1) + key; return; }
      }
      if (key == '.') {
        final parts = _expr.split(RegExp('[-+*/]'));
        if (parts.last.contains('.')) return;
        if (parts.last.isEmpty) { _expr += '0.'; return; }
      }
      _expr += key;
    });
  }

  Widget _key(String label, {Color? bg, Color? fg, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 62,
          decoration: BoxDecoration(color: bg ?? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(label, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: fg ?? Theme.of(context).colorScheme.onSurface))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = _eval(_expr);
    final opBg = Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6);
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.amount, style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: widget.color)),
                if (_expr.isNotEmpty) Text(_display(_expr), style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                if (_mem != 0) Padding(padding: const EdgeInsets.only(top: 4), child: ActionChip(label: Text('M ${_trim(_mem)}'), onPressed: () => _press('MR'))),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: widget.color, minimumSize: const Size(double.infinity, 54)),
              onPressed: value > 0 ? () => Navigator.pop(context, value) : null,
              child: Text(l10n.confirm, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _key('AC', bg: opBg, fg: accent, onTap: () => _press('AC'))),
                  Expanded(child: _key('M+', bg: opBg, fg: accent, onTap: () => _press('M+'))),
                  Expanded(child: _key('M-', bg: opBg, fg: accent, onTap: () => _press('M-'))),
                  Expanded(child: _key('⌫', bg: opBg, fg: accent, onTap: () => _press('DEL'))),
                ]),
                Row(children: [
                  Expanded(child: _key('7', onTap: () => _press('7'))),
                  Expanded(child: _key('8', onTap: () => _press('8'))),
                  Expanded(child: _key('9', onTap: () => _press('9'))),
                  Expanded(child: _key('÷', bg: opBg, fg: accent, onTap: () => _press('/'))),
                ]),
                Row(children: [
                  Expanded(child: _key('4', onTap: () => _press('4'))),
                  Expanded(child: _key('5', onTap: () => _press('5'))),
                  Expanded(child: _key('6', onTap: () => _press('6'))),
                  Expanded(child: _key('×', bg: opBg, fg: accent, onTap: () => _press('*'))),
                ]),
                Row(children: [
                  Expanded(child: _key('1', onTap: () => _press('1'))),
                  Expanded(child: _key('2', onTap: () => _press('2'))),
                  Expanded(child: _key('3', onTap: () => _press('3'))),
                  Expanded(child: _key('−', bg: opBg, fg: accent, onTap: () => _press('-'))),
                ]),
                Row(children: [
                  Expanded(child: _key('0', onTap: () => _press('0'))),
                  Expanded(child: _key('.', onTap: () => _press('.'))),
                  Expanded(child: _key('=', bg: opBg, fg: accent, onTap: () => _press('='))),
                  Expanded(child: _key('+', bg: opBg, fg: accent, onTap: () => _press('+'))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
""")

w('lib/features/shared/success_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../app/theme.dart';

class SuccessScreen extends StatelessWidget {
  final double amount;
  final String label;
  final Color color;
  const SuccessScreen({super.key, required this.amount, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(l10n.txSuccess, textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Text('حساباتي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                    const SizedBox(height: 6),
                    Text('${now.day}/${now.month}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(height: 20),
                    Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${amount.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(width: 8),
                        Text('Hesabaty', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                      onPressed: () => Share.share('$label: ${amount.toStringAsFixed(2)} ج.م'),
                      child: Text(l10n.share, style: const TextStyle(fontSize: 17)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue.withOpacity(0.15), foregroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 54)),
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.finish, style: const TextStyle(fontSize: 17)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
""")

w('lib/core/services/backup_service.dart', """import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class BackupService {
  static Future<String> _backupDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final backups = Directory('${dir.path}/backups');
    if (!await backups.exists()) await backups.create(recursive: true);
    return backups.path;
  }

  static Future<Map<String, dynamic>> _collect() async {
    final realm = await RealmService.realm;
    return {
      'version': 1,
      'date': DateTime.now().toIso8601String(),
      'contacts': realm.all<Contact>().map((c) => {
            'id': c.id.toString(),
            'businessId': c.businessId,
            'name': c.name,
            'phone': c.phone,
            'address': c.address,
            'type': c.type,
            'tags': c.tags.toList(),
            'createdAt': c.createdAt.toIso8601String(),
            'isDeleted': c.isDeleted,
          }).toList(),
      'cash': realm.all<CashTransaction>().map((t) => {
            'id': t.id.toString(),
            'businessId': t.businessId,
            'amount': t.amount,
            'type': t.type,
            'note': t.note,
            'date': t.date.toIso8601String(),
            'balanceAfter': t.balanceAfter,
            'status': t.status,
          }).toList(),
      'debt': realm.all<DebtTransaction>().map((t) => {
            'id': t.id.toString(),
            'contactId': t.contactId,
            'amount': t.amount,
            'type': t.type,
            'note': t.note,
            'date': t.date.toIso8601String(),
            'balanceAfter': t.balanceAfter,
            'status': t.status,
          }).toList(),
    };
  }

  static Future<File> exportBackup() async {
    final data = await _collect();
    final path = await _backupDir();
    final now = DateTime.now();
    final name = 'backup_${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';
    final file = File('$path/$name');
    final encoded = jsonEncode(data);
    await file.writeAsString(encoded);
    await File('$path/latest_backup.json').writeAsString(encoded);
    return file;
  }

  static Future<void> autoBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('auto_backup_enabled') ?? true;
      if (!enabled) return;
      final last = prefs.getInt('last_auto_backup') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - last < 24 * 60 * 60 * 1000) return;
      await exportBackup();
      await prefs.setInt('last_auto_backup', now);
    } catch (_) {}
  }

  static Future<void> restoreFromFile(String filePath) async {
    final content = await File(filePath).readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final realm = await RealmService.realm;
    realm.write(() {
      realm.deleteAll<DebtTransaction>();
      realm.deleteAll<CashTransaction>();
      realm.deleteAll<Contact>();
    });
    realm.write(() {
      for (final c in (data['contacts'] as List? ?? [])) {
        final m = c as Map<String, dynamic>;
        realm.add(Contact(
          ObjectId.fromHexString(m['id'] as String),
          (m['businessId'] as String?) ?? 'business_1',
          m['name'] as String,
          m['type'] as String,
          DateTime.parse(m['createdAt'] as String),
          phone: m['phone'] as String?,
          address: m['address'] as String?,
          tags: (m['tags'] as List? ?? []).cast<String>(),
          isDeleted: (m['isDeleted'] as bool?) ?? false,
        ));
      }
      for (final t in (data['cash'] as List? ?? [])) {
        final m = t as Map<String, dynamic>;
        realm.add(CashTransaction(
          ObjectId.fromHexString(m['id'] as String),
          (m['businessId'] as String?) ?? 'business_1',
          (m['amount'] as num).toDouble(),
          m['type'] as String,
          DateTime.parse(m['date'] as String),
          (m['balanceAfter'] as num).toDouble(),
          (m['status'] as String?) ?? 'active',
          note: m['note'] as String?,
        ));
      }
      for (final t in (data['debt'] as List? ?? [])) {
        final m = t as Map<String, dynamic>;
        realm.add(DebtTransaction(
          ObjectId.fromHexString(m['id'] as String),
          m['contactId'] as String,
          (m['amount'] as num).toDouble(),
          m['type'] as String,
          DateTime.parse(m['date'] as String),
          (m['balanceAfter'] as num).toDouble(),
          (m['status'] as String?) ?? 'active',
          note: m['note'] as String?,
        ));
      }
    });
  }
}
""")

w('lib/features/more/settings_screen.dart', """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app.dart';
import '../../app/theme.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/settings_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoBackup = true;
  String _lastBackup = '';

  @override
  void initState() {
    super.initState();
    _loadBackupInfo();
  }

  Future<void> _loadBackupInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('auto_backup_enabled') ?? true;
    final last = prefs.getInt('last_auto_backup') ?? 0;
    if (!mounted) return;
    setState(() {
      _autoBackup = enabled;
      _lastBackup = last == 0 ? '' : '${DateTime.fromMillisecondsSinceEpoch(last).toLocal()}';
    });
  }

  Future<void> _exportShare() async {
    final file = await BackupService.exportBackup();
    await Share.shareXFiles([XFile(file.path)], subject: 'Hesabaty Backup');
    _loadBackupInfo();
  }

  Future<void> _restore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final res = await FilePicker.platform.pickFiles();
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;
    try {
      await BackupService.restoreFromFile(path);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.restoreDone)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    void setLocale(String code) {
      ref.read(localeProvider.notifier).state = Locale(code);
      SettingsService.saveLocale(code);
    }

    void setTheme(ThemeMode mode, String code) {
      ref.read(themeModeProvider.notifier).state = mode;
      SettingsService.saveThemeMode(code);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.language, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(title: const Text('العربية'), value: 'ar', groupValue: locale.languageCode, onChanged: (v) => setLocale(v ?? 'ar')),
                RadioListTile<String>(title: const Text('English'), value: 'en', groupValue: locale.languageCode, onChanged: (v) => setLocale(v ?? 'en')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.appearance, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(title: Text(l10n.light), value: ThemeMode.light, groupValue: themeMode, onChanged: (v) => setTheme(ThemeMode.light, 'light')),
                RadioListTile<ThemeMode>(title: Text(l10n.dark), value: ThemeMode.dark, groupValue: themeMode, onChanged: (v) => setTheme(ThemeMode.dark, 'dark')),
                RadioListTile<ThemeMode>(title: Text(l10n.system), value: ThemeMode.system, groupValue: themeMode, onChanged: (v) => setTheme(ThemeMode.system, 'system')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.backupSection, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.autoBackupLabel),
                    value: _autoBackup,
                    onChanged: (v) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('auto_backup_enabled', v);
                      setState(() => _autoBackup = v);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('${l10n.lastBackupAt}: ${_lastBackup.isEmpty ? l10n.noBackup : _lastBackup}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(child: FilledButton(onPressed: _exportShare, child: Text(l10n.exportShare))),
                        const SizedBox(width: 8),
                        Expanded(child: OutlinedButton(onPressed: () => _restore(context), child: Text(l10n.restore))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
""")

p = 'lib/features/cash_book/cash_book_screen.dart'
s = open(p, encoding='utf-8').read()
s = s.replace("import 'package:share_plus/share_plus.dart';", "import 'package:share_plus/share_plus.dart';\nimport '../shared/amount_calculator_screen.dart';\nimport '../shared/success_screen.dart';")
s = s.replace("""            TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),""", """            InkWell(
              onTap: () async {
                final v = await Navigator.push<double>(context, MaterialPageRoute(builder: (_) => AmountCalculatorScreen(title: isIncome ? l10n.income : l10n.expense, color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed)));
                if (v != null) amountC.text = v.toString();
              },
              child: AbsorbPointer(
                child: TextField(controller: amountC, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
              ),
            ),""")
s = s.replace("""                if (ctx.mounted) Navigator.pop(ctx);
                _load();""", """                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessScreen(amount: amount, label: isIncome ? l10n.income : l10n.expense, color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed)));
                }
                _load();""")
open(p, 'w', encoding='utf-8').write(s)

p = 'lib/features/debt_book/contact_details_screen.dart'
s = open(p, encoding='utf-8').read()
s = s.replace("import 'package:share_plus/share_plus.dart';", "import 'package:share_plus/share_plus.dart';\nimport '../shared/amount_calculator_screen.dart';\nimport '../shared/success_screen.dart';")
s = s.replace("""            TextField(controller: amountC, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),""", """            InkWell(
              onTap: () async {
                final v = await Navigator.push<double>(context, MaterialPageRoute(builder: (_) => AmountCalculatorScreen(title: type == 'given' ? l10n.given : l10n.taken, color: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen)));
                if (v != null) amountC.text = v.toString();
              },
              child: AbsorbPointer(
                child: TextField(controller: amountC, decoration: InputDecoration(labelText: l10n.amount, border: const OutlineInputBorder())),
              ),
            ),""")
s = s.replace("""                if (ctx.mounted) Navigator.pop(ctx);
                _load();""", """                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SuccessScreen(amount: amount, label: type == 'given' ? l10n.given : l10n.taken, color: type == 'given' ? AppTheme.expenseRed : AppTheme.incomeGreen)));
                }
                _load();""")
open(p, 'w', encoding='utf-8').write(s)

p = 'lib/main.dart'
s = open(p, encoding='utf-8').read()
s = s.replace("import 'core/services/settings_service.dart';", "import 'core/services/settings_service.dart';\nimport 'core/services/backup_service.dart';")
s = s.replace("  runApp(", "  BackupService.autoBackup();\n  runApp(")
open(p, 'w', encoding='utf-8').write(s)

print("✅ Batch 6 completed: Calculator + Success + Backup!")
