import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> _products = [];
  String _query = '';
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final all = realm.all<Product>().where((p) => !p.isDeleted).toList();
    if (!mounted) return;
    setState(() => _products = all);
  }

  List<Product> get _filtered {
    var list = _products;
    if (_filter == 'low') list = list.where((p) => p.stock > 0 && p.stock <= p.minStock).toList();
    if (_filter == 'out') list = list.where((p) => p.stock <= 0).toList();
    if (_filter == 'ok') list = list.where((p) => p.stock > p.minStock).toList();
    if (_query.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(_query.toLowerCase()) || p.sku.toLowerCase().contains(_query.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final low = _products.where((p) => p.stock > 0 && p.stock <= p.minStock).length;
    final out = _products.where((p) => p.stock <= 0).length;
    final value = _products.fold<double>(0.0, (s, p) => s + p.stock * p.cost);
    final list = _filtered;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.inventory)),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
          _load();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _stat('${_products.length}', l10n.totalProducts, AppTheme.primaryBlue),
                _stat('${low + out}', l10n.lowStock, const Color(0xFFFF7043)),
                _stat('${value.toStringAsFixed(0)}', l10n.totalStockValue, const Color(0xFFE5A83B)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _chip('الكل', 'all', _filter, (v) => setState(() => _filter = v)),
                _chip(l10n.inStock, 'ok', _filter, (v) => setState(() => _filter = v), color: AppTheme.incomeGreen),
                _chip(l10n.lowStock, 'low', _filter, (v) => setState(() => _filter = v), color: const Color(0xFFFF7043)),
                _chip(l10n.outOfStock, 'out', _filter, (v) => setState(() => _filter = v), color: AppTheme.expenseRed),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('لا توجد منتجات', style: TextStyle(color: Colors.grey.shade500)),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final p = list[i];
                      final status = p.stock <= 0 ? 'out' : (p.stock <= p.minStock ? 'low' : 'ok');
                      final color = status == 'out' ? AppTheme.expenseRed : (status == 'low' ? const Color(0xFFFF7043) : AppTheme.incomeGreen);
                      final label = status == 'out' ? l10n.outOfStock : (status == 'low' ? l10n.lowStock : l10n.inStock);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p, onDone: _load))),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(Icons.inventory_2, color: color, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text('${p.category.isNotEmpty ? '${p.category} • ' : ''}${p.sku}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${p.stock.toStringAsFixed(0)} ${p.unit ?? l10n.piece}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${p.price.toStringAsFixed(2)} ${Cur.v}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, String current, ValueChanged<String> onTap, {Color? color}) {
    final sel = current == value;
    final c = color ?? AppTheme.primaryBlue;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        selectedColor: c.withOpacity(0.2),
        onSelected: (_) => onTap(value),
      ),
    );
  }
}
