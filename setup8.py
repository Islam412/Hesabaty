import os

def w(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

# 1. PDF Service with proper Arabic support
w('lib/core/services/pdf_service.dart', """import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart';
import '../../data/models/app_models.dart';

class PdfService {
  static String _fix(String text) {
    final reshaped = ArabicReshaper.reshape(text);
    return Bidi(reshaped).getVisual();
  }

  static Future<pw.Font> _arabicFont() async {
    try {
      final data = await GoogleFonts.getFont('Cairo').fontFamily != null
          ? (await rootBundle.load('assets/fonts/Cairo-Regular.ttf'))
          : (await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
      return pw.Font.ttf(data);
    } catch (_) {
      // Fallback to bundled asset
      final data = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      return pw.Font.ttf(data);
    }
  }

  static Future<File> generateContactStatement({
    required Contact contact,
    required String businessName,
    required List<DebtTransaction> transactions,
  }) async {
    final font = await _arabicFont();
    final pdf = pw.Document();

    final sorted = List<DebtTransaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    double bal = 0;
    final isCustomer = contact.type == 'customer';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        textDirection: pw.TextDirection.rtl,
        build: (ctx) {
          final rows = <List<String>>[];
          rows.add([
            _fix('التاريخ'),
            _fix('البيان'),
            _fix('مدفوع'),
            _fix('مقبوض'),
            _fix('الرصيد بعد'),
          ]);

          for (final t in sorted) {
            final sign = isCustomer
                ? (t.type == 'given' ? 1.0 : -1.0)
                : (t.type == 'taken' ? 1.0 : -1.0);
            bal += t.amount * sign;

            final given = (isCustomer && t.type == 'given') || (!isCustomer && t.type == 'taken')
                ? t.amount.toStringAsFixed(2)
                : '';
            final taken = (isCustomer && t.type == 'taken') || (!isCustomer && t.type == 'given')
                ? t.amount.toStringAsFixed(2)
                : '';

            rows.add([
              '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
              _fix(t.note ?? (isCustomer ? (t.type == 'given' ? 'معاملة مدفوعة' : 'معاملة مقبوضة') : (t.type == 'taken' ? 'معاملة مقبوضة' : 'معاملة مدفوعة'))),
              given,
              taken,
              bal.toStringAsFixed(2),
            ]);
          }

          return [
            pw.Center(
              child: pw.Text(
                _fix(businessName),
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                _fix('كشف حساب: ${contact.name}'),
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            if (contact.phone != null && contact.phone!.isNotEmpty)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(_fix('رقم الهاتف: ${contact.phone}'), style: const pw.TextStyle(fontSize: 12)),
              ),
            pw.SizedBox(height: 6),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                _fix('تاريخ التقرير: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: ctx,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
              cellAlignment: pw.Alignment.center,
              data: rows,
            ),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(_fix('الرصيد الحالي:'), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '${bal.abs().toStringAsFixed(2)} ج.م',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                _fix('تم إنشاء هذا التقرير بواسطة تطبيق حساباتي'),
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final safeName = contact.name.replaceAll(RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'), '_');
    final file = File('${dir.path}/statement_$safeName.pdf');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    return file;
  }
}
""")

# 2. Image Picker Helper
w('lib/core/services/image_picker_service.dart', """import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImagePickerService {
  static final _picker = ImagePicker();

  static Future<String?> pickAndSave({bool fromCamera = false}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final x = await _picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (x == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    final name = '${const Uuid().v4()}${p.extension(x.path)}';
    final dest = '${imagesDir.path}/$name';
    await File(x.path).copy(dest);
    return dest;
  }
}
""")

# 3. Contact Import Service
w('lib/core/services/contact_import_service.dart', """import 'package:flutter_contacts/flutter_contacts.dart';

class ImportedContact {
  final String name;
  final String phone;
  ImportedContact(this.name, this.phone);
}

class ContactImportService {
  static Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  static Future<List<ImportedContact>> importAll() async {
    final ok = await requestPermission();
    if (!ok) return [];
    final all = await FlutterContacts.getContacts(withProperties: true);
    final out = <ImportedContact>[];
    for (final c in all) {
      if (c.phones.isEmpty || c.displayName.trim().isEmpty) continue;
      final digits = c.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '');
      if (digits.length >= 8) {
        out.add(ImportedContact(c.displayName.trim(), digits));
      }
    }
    return out;
  }
}
""")

# 4. Import Contacts Screen
w('lib/features/debt_book/import_contacts_screen.dart', """import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../core/services/contact_import_service.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class ImportContactsScreen extends StatefulWidget {
  final bool isSupplier;
  const ImportContactsScreen({super.key, this.isSupplier = false});
  @override
  State<ImportContactsScreen> createState() => _ImportContactsScreenState();
}

class _ImportContactsScreenState extends State<ImportContactsScreen> {
  List<ImportedContact> _all = [];
  List<ImportedContact> _filtered = [];
  Set<int> _selected = {};
  bool _loading = true;
  bool _noPerm = false;
  final _q = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ok = await ContactImportService.requestPermission();
    if (!ok) {
      if (mounted) setState(() { _loading = false; _noPerm = true; });
      return;
    }
    final list = await ContactImportService.importAll();
    if (!mounted) return;
    setState(() {
      _all = list;
      _filtered = list;
      _loading = false;
    });
  }

  void _search(String v) {
    final q = v.toLowerCase();
    setState(() {
      _filtered = _all.where((c) => c.name.toLowerCase().contains(q) || c.phone.contains(q)).toList();
    });
  }

  Future<void> _import() async {
    if (_selected.isEmpty) return;
    final realm = await RealmService.realm;
    realm.write(() {
      for (final idx in _selected) {
        final c = _filtered[idx];
        realm.add(Contact(
          ObjectId(),
          'business_1',
          c.name,
          widget.isSupplier ? 'supplier' : 'customer',
          DateTime.now(),
          phone: c.phone,
        ));
      }
    });
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.importContacts),
        actions: [
          if (_selected.isNotEmpty)
            FilledButton.icon(
              onPressed: _import,
              icon: Icon(Icons.check, color: Colors.white),
              label: Text('${l10n.confirm} (${_selected.length})', style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _noPerm
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l10n.contactsDenied, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _q,
                        onChanged: _search,
                        decoration: InputDecoration(
                          hintText: l10n.search,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filtered.isEmpty
                          ? Center(child: Text(l10n.noBackup, style: TextStyle(color: Colors.grey.shade500)))
                          : ListView.builder(
                              itemCount: _filtered.length,
                              itemBuilder: (ctx, i) {
                                final c = _filtered[i];
                                final selected = _selected.contains(i);
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: (v) {
                                    setState(() {
                                      if (v == true) _selected.add(i); else _selected.remove(i);
                                    });
                                  },
                                  secondary: CircleAvatar(
                                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
                                    child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                                  ),
                                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(c.phone, style: TextStyle(color: Colors.grey.shade600)),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
""")

# 5. Update Add Contact screen to add import button
p = 'lib/features/debt_book/add_contact_screen.dart'
s = open(p, encoding='utf-8').read()
if "import 'import_contacts_screen.dart';" not in s:
    s = s.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'import_contacts_screen.dart';")
    s = s.replace("Widget build(BuildContext context) {", """Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_shortInitDone) {
      _shortInitDone = true;
      if (widget.isSupplier) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showShortChooser(l10n));
      }
    }""")
    s = s.replace("class _AddContactScreenState extends State<AddContactScreen> {", """class _AddContactScreenState extends State<AddContactScreen> {
  bool _shortInitDone = false;

  Future<void> _showShortChooser(AppLocalizations l10n) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_add, color: AppTheme.primaryBlue),
              title: Text(l10n.addSupplier),
              onTap: () => Navigator.pop(ctx, 'add'),
            ),
            ListTile(
              leading: Icon(Icons.contacts, color: AppTheme.primaryBlue),
              title: Text(l10n.importContacts),
              onTap: () => Navigator.pop(ctx, 'import'),
            ),
          ],
        ),
      ),
    );
    if (choice == 'import' && mounted) {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ImportContactsScreen(isSupplier: true)));
      if (result == true && mounted) Navigator.pop(context, true);
    } else if (choice == null && mounted) {
      Navigator.pop(context);
    }
  }
""")
    open(p, 'w', encoding='utf-8').write(s)

# 6. Update Cash Transaction add sheet with image picker
p = 'lib/features/cash_book/cash_book_screen.dart'
s = open(p, encoding='utf-8').read()
if "import '../../core/services/image_picker_service.dart';" not in s:
    s = s.replace("import '../../data/services/realm_service.dart';", "import '../../data/services/realm_service.dart';\nimport '../../core/services/image_picker_service.dart';\nimport 'dart:io';")
    s = s.replace("""  Future<void> _add(String type) async {
    final amountC = TextEditingController();
    final noteC = TextEditingController();""", """  Future<void> _add(String type) async {
    final amountC = TextEditingController();
    final noteC = TextEditingController();
    String? _imgPath;""")
    s = s.replace("""            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),""", """            const SizedBox(height: 12),
            TextField(controller: noteC, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
            StatefulBuilder(
              builder: (ctx, setS) => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: OutlinedButton.icon(onPressed: () async { final p = await ImagePickerService.pickAndSave(fromCamera: true); if (p != null) setS(() => _imgPath = p); }, icon: const Icon(Icons.camera_alt), label: Text(l10n.note))),
                        const SizedBox(width: 8),
                        Expanded(child: OutlinedButton.icon(onPressed: () async { final p = await ImagePickerService.pickAndSave(fromCamera: false); if (p != null) setS(() => _imgPath = p); }, icon: const Icon(Icons.photo), label: Text(l10n.note))),
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
            ),""")
    s = s.replace("""                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),""", """                    note: noteC.text.trim().isEmpty ? null : noteC.text.trim(),
                    imagePath: _imgPath,""")
    open(p, 'w', encoding='utf-8').write(s)

# 7. Update Contact Details screen with PDF export + image on transactions
p = 'lib/features/debt_book/contact_details_screen.dart'
s = open(p, encoding='utf-8').read()
if "import '../../core/services/pdf_service.dart';" not in s:
    s = s.replace("import '../../data/services/realm_service.dart';", "import '../../data/services/realm_service.dart';\nimport '../../core/services/pdf_service.dart';\nimport 'dart:io';")
    s = s.replace("""          IconButton(icon: const Icon(Icons.message_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),""", """          IconButton(icon: const Icon(Icons.picture_as_pdf_outlined), onPressed: () async {
            final file = await PdfService.generateContactStatement(contact: widget.contact, businessName: 'حساباتي', transactions: _txs);
            if (context.mounted) await Share.shareXFiles([XFile(file.path)], subject: 'Statement - ${widget.contact.name}');
          }),
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),""")
    # Add image preview to transaction list items
    s = s.replace("""                          subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year}  ${t.note ?? ''}'),""", """                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${t.date.day}/${t.date.month}/${t.date.year}  ${t.note ?? ''}'),
                              if (t.imagePath != null && t.imagePath!.isNotEmpty && File(t.imagePath!).existsSync())
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(t.imagePath!), height: 60, width: 60, fit: BoxFit.cover)),
                                ),
                            ],
                          ),""")
    open(p, 'w', encoding='utf-8').write(s)

# 8. Update Realm models to include imagePath properly (check and add if missing)
p = 'lib/data/models/app_models.dart'
s = open(p, encoding='utf-8').read()
if 'String? imagePath;' not in s:
    s = s.replace("  String? note;\n  late DateTime date;", "  String? note;\n  String? imagePath;\n  late DateTime date;")
    open(p, 'w', encoding='utf-8').write(s)

# 9. Setup Cairo font asset
import os
os.makedirs('assets/fonts', exist_ok=True)
import urllib.request
try:
    urllib.request.urlretrieve('https://github.com/googlefonts/cairo/raw/main/fonts/ttf/Cairo-Regular.ttf', 'assets/fonts/Cairo-Regular.ttf')
    print("✅ Cairo font downloaded")
except Exception as e:
    print(f"⚠️  Could not download Cairo font: {e}")
    print("⚠️  Please download manually from: https://fonts.google.com/specimen/Cairo")

# 10. Update pubspec.yaml to add assets
p = 'pubspec.yaml'
s = open(p, encoding='utf-8').read()
if 'assets/fonts/' not in s:
    s = s.replace("""flutter:
  generate: true
  uses-material-design: true""", """flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/fonts/""")
    open(p, 'w', encoding='utf-8').write(s)

print("✅ Batch 8: PDF Export + Image Attachments + Contact Import ready!")
