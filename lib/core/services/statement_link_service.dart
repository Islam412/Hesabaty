import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_service.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/app_models.dart';

class StatementLinkService {
  static const String baseUrl = 'https://cash-rest.vercel.app/';

  static Future<String> generateLink(Contact contact, List<DebtTransaction> txs, double balance, {List<Map<String, String>> payMethods = const []}) async {
    final prefs = await AccPrefs.scoped();
    final sp = (prefs.getString('profile_phone') ?? prefs.getString('user_phone')) ?? '';
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
    final map = {
      'id': const Uuid().v4(),
      'sn': prefs.getString('profile_name') ?? 'حساباتي',
      'sp': sp.isNotEmpty ? '+$sp' : '',
      'n': contact.name,
      'p': contact.phone ?? '',
      'b': balance,
      'g': given,
      'k': taken,
      't': rows,
      'pay': payMethods,
    };
    final gz = gzip.encode(utf8.encode(jsonEncode(map)));
    final b64 = base64Url.encode(gz).replaceAll('=', '');
    return '$baseUrl#$b64';
  }

  static Future<String> statementText(Contact contact, List<DebtTransaction> txs, double balance) async {
    final prefs = await AccPrefs.scoped();
    final sp = (prefs.getString('profile_phone') ?? prefs.getString('user_phone')) ?? '';
    final sb = StringBuffer();
    sb.writeln('كشف حساب: ${contact.name}${(contact.phone ?? '').isNotEmpty ? ' (${contact.phone})' : ''}');
    sb.writeln('من: ${prefs.getString('profile_name') ?? 'حساباتي'} ${sp.isNotEmpty ? '+$sp' : ''}');
    sb.writeln('ليك رصيد');
    sb.writeln('-----');
    sb.writeln('${balance.abs().toStringAsFixed(2)} ج.م.');
    sb.writeln('-----');
    final sorted = List<DebtTransaction>.from(txs)..sort((a, b) => b.date.compareTo(a.date));
    for (final t in sorted) {
      sb.writeln('${t.date.day}/${t.date.month}/${t.date.year}  ${t.type == 'given' ? 'مدفوع' : 'مقبوض'}  ${t.amount.toStringAsFixed(2)} ج.م  ${t.note ?? ''}');
    }
    sb.writeln('-----');
    return sb.toString();
  }
}
