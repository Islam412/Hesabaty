import 'package:realm/realm.dart';

part 'app_models.realm.dart';

@RealmModel()
class _Business {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String name;
  late String? phone;
  late String? address;
  late String currency;
  late DateTime createdAt;
  late bool isDeleted = false;
}

@RealmModel()
class _Contact {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String businessId;
  late String name;
  late String type;
  late DateTime createdAt;
  late String? phone;
  late String? address;
  late List<String> tags;
  late bool isDeleted = false;
}

@RealmModel()
class _CashTransaction {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String businessId;
  late double amount;
  late String type;
  late DateTime date;
  late double balanceAfter;
  late String status;
  late String? note;
  late String? imagePath;
}

@RealmModel()
class _DebtTransaction {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String contactId;
  late double amount;
  late String type;
  late DateTime date;
  late double balanceAfter;
  late String status;
  late String? note;
  late String? imagePath;
}

@RealmModel()
class _Reminder {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late DateTime dueDate;
  late String message;
  late String? contactId;
  late bool isDone = false;
}

@RealmModel()
class _LinkedCard {
  @PrimaryKey()
  @MapTo('id')
  late String id;
  late String businessId;
  late String last4;
  late String brand;
  late String expiry;
  late String cardholderName;
  late String token;
  late bool isDefault;
  late String? bank;
  late double? balance;
  late DateTime addedAt;
}

@RealmModel()
class _WalletTransaction {
  @PrimaryKey()
  @MapTo('id')
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

@RealmModel()
class _Product {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String businessId;
  late String name;
  late String sku;
  late String category;
  late double price;
  late double cost;
  late double stock;
  late double minStock;
  late String? unit;
  late String? notes;
  late DateTime createdAt;
  late bool isDeleted;
}

@RealmModel()
class _StockMovement {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String productId;
  late String type;
  late double quantity;
  late double unitPrice;
  late DateTime date;
  late String? note;
  late String status;
}



@RealmModel()
class _StaffPayment {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String staffId;
  late double amount;
  late String type;
  late DateTime date;
  late String? note;
  late String status;
}

@RealmModel()
class _StaffAttendance {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String staffId;
  late DateTime date;
  late String status;
  late String? note;
}

@RealmModel()
class _Staff {
  @PrimaryKey()
  @MapTo('id')
  late ObjectId id;
  late String businessId;
  late String name;
  late String role;
  late String? phone;
  late String? address;
  late double salary;
  late String salaryType;
  late DateTime joinDate;
  late bool isActive;
  late String? notes;
  late DateTime createdAt;
}
