import 'package:flutter/material.dart';
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
