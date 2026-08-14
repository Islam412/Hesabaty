import 'dart:convert';
import 'dart:io';
import '../../data/models/app_models.dart';

class StatementLinkService {
  // ⚠️ غيّر الرابط ده لرابط صفحتك المجانية على GitHub Pages بعد ما ترفعها (الخطوات تحت)
  static const String baseUrl = 'https://islam412.github.io/hesabaty';

  static String generateLink(Contact contact, List<DebtTransaction> txs, double balance) {
    final isCustomer = contact.type == 'customer';
    double given = 0;
    double taken = 0;
    final rows = <List<dynamic>>[];
    final sorted = List<DebtTransaction>.from(txs)..sort((a, b) => a.date.compareTo(b.date));
    for (final t in sorted) {
      final isGiven = isCustomer ? t.type == 'given' : t.type == 'taken';
      if (isGiven) { given += t.amount; } else { taken += t.amount; }
      rows.add([
        '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}',
        isGiven ? 'given' : 'taken',
        t.amount,
        t.note ?? '',
      ]);
    }
    final map = {'n': contact.name, 'p': contact.phone ?? '', 'b': balance, 'g': given, 'k': taken, 't': rows};
    final gz = gzip.encode(utf8.encode(jsonEncode(map)));
    final b64 = base64Url.encode(gz).replaceAll('=', '');
    return '$baseUrl/#$b64';
  }

  static String statementText(Contact contact, List<DebtTransaction> txs, double balance) {
    final sb = StringBuffer();
    sb.writeln('كشف حساب: ${contact.name}');
    sb.writeln('------------------');
    final sorted = List<DebtTransaction>.from(txs)..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      sb.writeln('${t.date.day}/${t.date.month}/${t.date.year}  ${t.type == 'given' ? 'مدفوع' : 'مقبوض'}  ${t.amount.toStringAsFixed(2)} ج.م  ${t.note ?? ''}');
    }
    sb.writeln('------------------');
    sb.writeln('الرصيد الحالي: ${balance.abs().toStringAsFixed(2)} ج.م');
    return sb.toString();
  }
}
