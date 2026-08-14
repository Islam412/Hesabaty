import 'dart:math';
import 'package:realm/realm.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'payment_provider.dart';

class BillPaymentResult {
  final bool success;
  final String? reference;
  final String? error;
  BillPaymentResult({required this.success, this.reference, this.error});
}

class BillPaymentService {
  static Future<BillPaymentResult> pay({
    required String categoryId,
    required String categoryLabel,
    required String providerId,
    required String providerLabel,
    required String account,
    required double amount,
    required LinkedCard fromCard,
  }) async {
    // محاكاة عملية الدفع
    await Future.delayed(const Duration(milliseconds: 1500));
    final rand = Random();
    final ref = 'BILL${DateTime.now().millisecondsSinceEpoch}${rand.nextInt(9999)}';
    
    final success = rand.nextDouble() > 0.05; // 95% نجاح
    if (!success) {
      return BillPaymentResult(success: false, error: 'فشل الاتصال بمزود الخدمة، حاول تاني');
    }

    // حفظ العملية في قاعدة البيانات
    try {
      final realm = await RealmService.realm;
      final txId = ObjectId().toString();
      final bal = await _getBalance();
      final newBal = bal - amount;
      realm.write(() {
        realm.add(WalletTransaction(
          txId,
          'business_1',
          'bill',
          amount,
          providerId,
          account,
          categoryId,
          'success',
          DateTime.now(),
          newBal,
          reference: ref,
          note: '$categoryLabel - $providerLabel',
        ));
      });
    } catch (_) {}

    return BillPaymentResult(success: true, reference: ref);
  }

  static Future<double> _getBalance() async {
    final realm = await RealmService.realm;
    final txs = realm.all<WalletTransaction>().where((t) => t.status == 'success').toList();
    double bal = 0;
    for (final t in txs) {
      if (t.type == 'topup' || t.type == 'receive') bal += t.amount;
      else bal -= t.amount;
    }
    return bal;
  }
}
