import 'package:realm/realm.dart';
import '../../data/models/app_models.dart';
import '../../data/services/realm_service.dart';
import 'payment_provider.dart';

class WalletService {
  static final PaymentProvider provider = MockPaymentProvider();

  static Future<double> getBalance() async {
    final realm = await RealmService.realm;
    final txs = realm.all<WalletTransaction>().where((t) => t.status == 'success').toList();
    double bal = 0;
    for (final t in txs) {
      if (t.type == 'topup' || t.type == 'receive') bal += t.amount;
      else if (t.type == 'send') bal -= t.amount;
    }
    return bal;
  }

  static Future<List<LinkedCard>> getCards() async {
    final realm = await RealmService.realm;
    return realm.all<LinkedCard>().toList();
  }

  static Future<LinkedCard> addCard({
    required String number,
    required String name,
    required String expiry,
    required String cvv,
  }) async {
    final realm = await RealmService.realm;
    final brand = _detectBrand(number);
    final last4 = number.substring(number.length - 4);
    final id = ObjectId().toString();
    final card = LinkedCard(
      id,
      'business_1',
      last4,
      brand,
      expiry,
      name,
      'tok_mock_$id',
      false,
      DateTime.now(),
    );
    realm.write(() => realm.add(card));
    return card;
  }

  static String _detectBrand(String number) {
    final n = number.replaceAll(RegExp(r'\s'), '');
    if (n.startsWith('4')) return 'Visa';
    if (n.startsWith('5') || n.startsWith('2')) return 'Mastercard';
    if (n.startsWith('3')) return 'Amex';
    if (n.startsWith('6')) return 'Meeza';
    return 'Card';
  }

  static bool luhnCheck(String number) {
    final digits = number.replaceAll(RegExp(r'\s'), '');
    if (digits.length < 13 || digits.length > 19) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static Future<void> removeCard(String id) async {
    final realm = await RealmService.realm;
    final card = realm.find<LinkedCard>(id);
    if (card != null) realm.write(() => realm.delete(card));
  }

  static Future<PaymentResult> send({
    required double amount,
    required String destination,
    required String destinationType,
    required LinkedCard fromCard,
    String? note,
  }) async {
    final bal = await getBalance();
    final realm = await RealmService.realm;
    final id = ObjectId().toString();

    final result = await provider.sendMoney(
      amount: amount,
      destination: destination,
      destinationType: destinationType,
      fromCard: fromCard,
      note: note,
    );

    final newBal = bal - amount;
    realm.write(() {
      realm.add(WalletTransaction(
        id,
        'business_1',
        'send',
        amount,
        destinationType,
        destination,
        destinationType,
        result.success ? 'success' : 'failed',
        DateTime.now(),
        newBal,
        reference: result.reference,
        note: note,
      ));
    });
    return result;
  }

  static Future<PaymentResult> topUp({
    required double amount,
    required LinkedCard fromCard,
  }) async {
    final bal = await getBalance();
    final realm = await RealmService.realm;
    final id = ObjectId().toString();

    final result = await provider.topUp(amount: amount, fromCard: fromCard);
    final newBal = bal + amount;
    realm.write(() {
      realm.add(WalletTransaction(
        id,
        'business_1',
        'topup',
        amount,
        'card',
        fromCard.last4,
        fromCard.brand,
        result.success ? 'success' : 'failed',
        DateTime.now(),
        newBal,
        reference: result.reference,
        note: null,
      ));
    });
    return result;
  }

  static Future<List<WalletTransaction>> getTransactions() async {
    final realm = await RealmService.realm;
    final txs = realm.all<WalletTransaction>().toList();
    txs.sort((a, b) => b.date.compareTo(a.date));
    return txs;
  }
}
