import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;
  const AddProductScreen({super.key, this.product});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _cost = TextEditingController();
  final _stock = TextEditingController();
  final _min = TextEditingController();
  final _unit = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _name.text = p.name; _sku.text = p.sku; _category.text = p.category;
      _price.text = p.price.toString(); _cost.text = p.cost.toString();
      _stock.text = p.stock.toString(); _min.text = p.minStock.toString();
      _unit.text = p.unit ?? ''; _notes.text = p.notes ?? '';
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.productName} مطلوب'), backgroundColor: AppTheme.expenseRed));
      return;
    }
    final realm = await RealmService.realm;
    realm.write(() {
      if (widget.product == null) {
        realm.add(Product(
          ObjectId(), 'business_1',
          _name.text.trim(), _sku.text.trim(), _category.text.trim(),
          double.tryParse(_price.text) ?? 0, double.tryParse(_cost.text) ?? 0,
          double.tryParse(_stock.text) ?? 0, double.tryParse(_min.text) ?? 5,
          DateTime.now(), false,
          unit: _unit.text.trim().isEmpty ? null : _unit.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ));
      } else {
        final p = widget.product!;
        p.name = _name.text.trim(); p.sku = _sku.text.trim(); p.category = _category.text.trim();
        p.price = double.tryParse(_price.text) ?? 0; p.cost = double.tryParse(_cost.text) ?? 0;
        p.stock = double.tryParse(_stock.text) ?? 0; p.minStock = double.tryParse(_min.text) ?? 5;
        p.unit = _unit.text.trim().isEmpty ? null : _unit.text.trim();
        p.notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
      }
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.save} ✓'), backgroundColor: AppTheme.incomeGreen));
    Navigator.pop(context);
  }

  Widget _field(TextEditingController c, String label, {TextInputType? kb, String? hint}) {
    return TextField(controller: c, keyboardType: kb, decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? l10n.addProduct : l10n.editProduct)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _field(_name, l10n.productName),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _field(_sku, l10n.sku)), const SizedBox(width: 12), Expanded(child: _field(_category, l10n.category))]),
          const SizedBox(height: 12),
          Row(children: [Expanded(child: _field(_price, l10n.price, kb: const TextInputType.numberWithOptions(decimal: true))), const SizedBox(width: 12), Expanded(child: _field(_cost, l10n.cost, kb: const TextInputType.numberWithOptions(decimal: true)))]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(_stock, l10n.stock, kb: const TextInputType.numberWithOptions(decimal: true))),
            const SizedBox(width: 12),
            Expanded(child: _field(_min, l10n.minStock, kb: const TextInputType.numberWithOptions(decimal: true))),
            const SizedBox(width: 12),
            Expanded(child: _field(_unit, l10n.unit, hint: l10n.piece)),
          ]),
          const SizedBox(height: 12),
          _field(_notes, l10n.note),
          const SizedBox(height: 20),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _save, child: Text(l10n.save, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
