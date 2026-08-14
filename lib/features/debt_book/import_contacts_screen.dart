import 'package:flutter/material.dart';
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
