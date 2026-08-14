import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'import_contacts_screen.dart';

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
      isDeleted: false,
        ObjectId(),
        'business_1',
        _name.text.trim(),
        widget.isSupplier ? 'supplier' : 'customer',
        DateTime.now(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        tags: _tags,
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
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => ImportContactsScreen(isSupplier: widget.isSupplier)));
              if (result == true && mounted) Navigator.pop(context, true);
            },
            icon: const Icon(Icons.contacts),
            label: Text(l10n.importContacts),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
