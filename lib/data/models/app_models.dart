import 'package:realm/realm.dart';

part 'app_models.realm.dart';

@RealmModel()
class _Business {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String name;
  String? logoPath;
  String? phone;
  String? address;
  late DateTime createdAt;
}

@RealmModel()
class _Contact {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String businessId;
  late String name;
  String? phone;
  String? address;
  late String type; // 'customer' or 'supplier'
  late List<String> tags;
  late DateTime createdAt;
  bool isDeleted = false;
}

@RealmModel()
class _CashTransaction {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String businessId;
  late double amount;
  late String type; // 'income' or 'expense'
  String? note;
  String? imagePath;
  late DateTime date;
  late double balanceAfter;
  late String status; // 'active', 'edited', 'deleted'
}

@RealmModel()
class _DebtTransaction {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String contactId;
  late double amount;
  late String type; // 'given' or 'taken'
  String? note;
  String? imagePath;
  late DateTime date;
  late double balanceAfter;
  late String status; // 'active', 'edited', 'deleted'
}

@RealmModel()
class _Reminder {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  String? contactId;
  String? cashEntryId;
  late DateTime dueDate;
  late String message;
  bool isDone = false;
}

@RealmModel()
class _LinkedCard {
  @PrimaryKey()
  late String id;
  late String businessId;
  late String last4;
  late String brand;
  late String expiry;
  late String cardholderName;
  late String token;
  late bool isDefault;
  late DateTime addedAt;
}

@RealmModel()
class _WalletTransaction {
  @PrimaryKey()
  late String id;
  late String businessId;
  late String type;
  late double amount;
  late String provider;
  late String destination;
  late String destinationType;
  late String status;
  late String? reference;
  late String? note;
  late DateTime date;
  late double balanceAfter;
}
