import 'package:flutter/material.dart';
import '../../app/theme.dart';

class CalculatorSheet extends StatefulWidget {
  final double initialValue;
  final String title;
  final String currency;
  const CalculatorSheet({super.key, this.initialValue = 0, this.title = 'المبلغ', this.currency = 'ج.م'});

  static Future<double?> show(BuildContext context, {double initial = 0, String title = 'المبلغ', String currency = 'ج.م'}) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CalculatorSheet(initialValue: initial, title: title, currency: currency),
    );
  }

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  String _display = '0';
  String _buffer = '0';
  String _op = '';
  bool _justEval = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue > 0) {
      _display = _fmt(widget.initialValue);
      _buffer = widget.initialValue.toString();
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  double _parse(String s) => double.tryParse(s.replaceAll(',', '')) ?? 0;

  void _digit(String d) {
    setState(() {
      if (_justEval) { _display = '0'; _justEval = false; }
      if (_display == '0' && d != '.') _display = d;
      else if (d == '.' && _display.contains('.')) return;
      else _display += d;
    });
  }

  void _opPressed(String o) {
    setState(() {
      if (_op.isNotEmpty && !_justEval) _calc();
      _buffer = _display;
      _op = o;
      _justEval = true;
    });
  }

  void _calc() {
    final a = _parse(_buffer);
    final b = _parse(_display);
    double r = 0;
    switch (_op) {
      case '+': r = a + b; break;
      case '-': r = a - b; break;
      case '×': r = a * b; break;
      case '÷': r = b != 0 ? a / b : 0; break;
    }
    _display = _fmt(r);
    _buffer = r.toString();
    _op = '';
    _justEval = true;
  }

  void _equals() {
    setState(() {
      if (_op.isNotEmpty) _calc();
    });
  }

  void _clear() => setState(() { _display = '0'; _buffer = '0'; _op = ''; _justEval = false; });
  void _back() {
    setState(() {
      if (_display.length <= 1) _display = '0';
      else _display = _display.substring(0, _display.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Text(widget.title, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_display ${widget.currency}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue), textDirection: TextDirection.ltr),
                InkWell(onTap: _back, child: const Icon(Icons.backspace_outlined, size: 28, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _row(['C', '±', '%', '÷']),
                _row(['7', '8', '9', '×']),
                _row(['4', '5', '6', '-']),
                _row(['1', '2', '3', '+']),
                _row(['00', '0', '.', '✓']),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _row(List<String> keys) {
    return Row(
      children: keys.map((k) => Expanded(child: _key(k))).toList(),
    );
  }

  Widget _key(String k) {
    Color bg = Colors.white;
    Color fg = const Color(0xFF16324F);
    bool isOp = false, isDone = false, isClear = false;
    if (['÷', '×', '-', '+'].contains(k)) { bg = AppTheme.primaryBlue.withOpacity(0.12); fg = AppTheme.primaryBlue; isOp = true; }
    else if (k == '✓') { bg = AppTheme.incomeGreen; fg = Colors.white; isDone = true; }
    else if (k == 'C') { bg = AppTheme.expenseRed.withOpacity(0.12); fg = AppTheme.expenseRed; isClear = true; }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (k == '✓') { if (_op.isNotEmpty) _calc(); Navigator.pop(context, _parse(_display)); }
            else if (k == 'C') _clear();
            else if (k == '±') setState(() => _display = _display.startsWith('-') ? _display.substring(1) : '-$_display');
            else if (k == '%') setState(() => _display = _fmt(_parse(_display) / 100));
            else if (isOp) _opPressed(k);
            else if (k == '.') _digit('.');
            else _digit(k);
          },
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Center(child: Text(k, style: TextStyle(fontSize: k == '✓' ? 26 : 22, fontWeight: FontWeight.bold, color: fg))),
          ),
        ),
      ),
    );
  }
}

// Helper: حقل مبلغ يفتح الآلة الحاسبة
class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String currency;
  final Color color;
  const AmountField({super.key, required this.controller, this.label = 'المبلغ', this.currency = 'ج.م', this.color = const Color(0xFF2E7CF6)});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final cur = double.tryParse(controller.text.replaceAll(',', '')) ?? 0;
        final r = await CalculatorSheet.show(context, initial: cur, title: label, currency: currency);
        if (r != null) {
          controller.text = r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(2);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          suffixIcon: Icon(Icons.calculate, color: color),
        ),
        child: Text(
          controller.text.isEmpty ? '0' : controller.text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          textDirection: TextDirection.ltr,
        ),
      ),
    );
  }
}
