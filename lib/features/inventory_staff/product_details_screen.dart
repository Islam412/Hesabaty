import '../../core/widgets/calculator_sheet.dart';
import 'package:flutter/material.dart';
import 'package:debt_cash_app/l10n/app_localizations.dart';
import 'package:realm/realm.dart';
import '../../app/theme.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'add_product_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final VoidCallback onDone;
  const ProductDetailsScreen({super.key, required this.product, required this.onDone});
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<StockMovement> _moves = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final realm = await RealmService.realm;
    final pid = widget.product.id.toString();
    final m = realm.all<StockMovement>().where((x) => x.productId == pid && x.status != 'deleted').toList();
    m.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() => _moves = m);
  }

  Future<void> _move(String type) async {
    final l10n = AppLocalizations.of(context)!;
    final qty = TextEditingController();
    final price = TextEditingController(text: widget.product.cost.toString());
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(type == 'in' ? l10n.addStock : l10n.removeStock),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qty, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.stock, border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: l10n.cost, border: const OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: note, decoration: InputDecoration(labelText: l10n.note, border: const OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save)),
        ],
      ),
    );
    if (ok != true) return;
    final q = double.tryParse(qty.text) ?? 0;
    if (q <= 0) return;
    if (type == 'out' && q > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.insufficientBalance), backgroundColor: AppTheme.expenseRed));
      return;
    }
    final realm = await RealmService.realm;
    realm.write(() {
      realm.add(StockMovement(ObjectId(), widget.product.id.toString(), type, q, double.tryParse(price.text) ?? 0, DateTime.now(), 'active', note: note.text.trim().isEmpty ? null : note.text.trim()));
      if (type == 'in') widget.product.stock = widget.product.stock + q;
      else widget.product.stock = widget.product.stock - q;
    });
    widget.onDone();
    _load();
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('حذف'),
      content: const Text('تأكيد حذف المنتج؟'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف'))],
    ));
    if (ok != true) return;
    final realm = await RealmService.realm;
    realm.write(() => widget.product.isDeleted = true);
    widget.onDone();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = widget.product;
    final status = p.stock <= 0 ? 'out' : (p.stock <= p.minStock ? 'low' : 'ok');
    final color = status == 'out' ? AppTheme.expenseRed : (status == 'low' ? const Color(0xFFFF7043) : AppTheme.incomeGreen);
    final value = p.stock * p.cost;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductScreen(product: p)));
            widget.onDone();
            if (mounted) setState(() {});
          }),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text('${p.stock.toStringAsFixed(0)} ${p.unit ?? l10n.piece}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                Text(l10n.stock, style: const TextStyle(color: Color(0xFFE8F0FE), fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(status == 'out' ? l10n.outOfStock : (status == 'low' ? l10n.lowStock : l10n.inStock), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _info('السعر', '${p.price.toStringAsFixed(2)} ${Cur.v}', AppTheme.primaryBlue),
              _info('التكلفة', '${p.cost.toStringAsFixed(2)} ${Cur.v}', const Color(0xFFFF7043)),
              _info('القيمة', '${value.toStringAsFixed(2)} ${Cur.v}', const Color(0xFFE5A83B)),
            ],
          ),
          if (p.category.isNotEmpty) _detailRow(Icons.category, l10n.category, p.category),
          if (p.sku.isNotEmpty) _detailRow(Icons.qr_code, l10n.sku, p.sku),
          if (p.unit != null) _detailRow(Icons.straighten, l10n.unit, p.unit!),
          _detailRow(Icons.warning_amber, l10n.minStock, p.minStock.toStringAsFixed(0)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.incomeGreen.withOpacity(0.85), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => _move('in'),
                icon: const Icon(Icons.add),
                label: Text(l10n.addStock),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppTheme.expenseRed.withOpacity(0.85), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => _move('out'),
                icon: const Icon(Icons.remove),
                label: Text(l10n.removeStock),
              )),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.stockMovement, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_moves.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('لا توجد حركات', style: TextStyle(color: Colors.grey.shade500))))
          else
            ..._moves.map((m) {
              final isIn = m.type == 'in';
              final c = isIn ? AppTheme.incomeGreen : AppTheme.expenseRed;
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: c.withOpacity(0.15), child: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, color: c)),
                  title: Text(isIn ? l10n.addStock : l10n.removeStock, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${m.date.day}/${m.date.month}/${m.date.year}${m.note != null ? ' • ${m.note}' : ''}', style: const TextStyle(fontSize: 12)),
                  trailing: Text('${isIn ? '+' : '-'}${m.quantity.toStringAsFixed(0)} ${p.unit ?? l10n.piece}', style: TextStyle(color: c, fontWeight: FontWeight.bold)),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _info(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
