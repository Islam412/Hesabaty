import 'dart:math';
import '../../data/models/app_models.dart';

abstract class PaymentProvider {
  Future<PaymentResult> sendMoney({
    required double amount,
    required String destination,
    required String destinationType,
    required LinkedCard fromCard,
    String? note,
  });

  Future<PaymentResult> topUp({
    required double amount,
    required LinkedCard fromCard,
  });
}

class PaymentResult {
  final bool success;
  final String? reference;
  final String? error;
  PaymentResult({required this.success, this.reference, this.error});
}

class MockPaymentProvider extends PaymentProvider {
  @override
  Future<PaymentResult> sendMoney({
    required double amount,
    required String destination,
    required String destinationType,
    required LinkedCard fromCard,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final rand = Random();
    final ref = 'IP${DateTime.now().millisecondsSinceEpoch}${rand.nextInt(9999)}';
    if (amount > 50000) {
      return PaymentResult(success: false, error: 'الحد الأقصى 50,000 ج.م للعملية الواحدة');
    }
    return PaymentResult(success: true, reference: ref);
  }

  @override
  Future<PaymentResult> topUp({required double amount, required LinkedCard fromCard}) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final ref = 'TU${DateTime.now().millisecondsSinceEpoch}';
    return PaymentResult(success: true, reference: ref);
  }
}

// TODO: لاحقاً — استبدل بـ PaymobProvider لما تجيب API Key
// class PaymobProvider extends PaymentProvider { ... }
