// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Business extends _Business
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Business(
    ObjectId id,
    String name,
    String currency,
    DateTime createdAt, {
    String? phone,
    String? address,
    bool isDeleted = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Business>({
        'isDeleted': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'currency', currency);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
  }

  Business._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  String get currency =>
      RealmObjectBase.get<String>(this, 'currency') as String;
  @override
  set currency(String value) => RealmObjectBase.set(this, 'currency', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<Business>> get changes =>
      RealmObjectBase.getChanges<Business>(this);

  @override
  Stream<RealmObjectChanges<Business>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Business>(this, keyPaths);

  @override
  Business freeze() => RealmObjectBase.freezeObject<Business>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'currency': currency.toEJson(),
      'createdAt': createdAt.toEJson(),
      'isDeleted': isDeleted.toEJson(),
    };
  }

  static EJsonValue _toEJson(Business value) => value.toEJson();
  static Business _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'currency': EJsonValue currency,
        'createdAt': EJsonValue createdAt,
      } =>
        Business(
          fromEJson(id),
          fromEJson(name),
          fromEJson(currency),
          fromEJson(createdAt),
          phone: fromEJson(ejson['phone']),
          address: fromEJson(ejson['address']),
          isDeleted: fromEJson(ejson['isDeleted'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Business._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Business, 'Business', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('currency', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Contact extends _Contact with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Contact(
    ObjectId id,
    String businessId,
    String name,
    String type,
    DateTime createdAt, {
    String? phone,
    String? address,
    Iterable<String> tags = const [],
    bool isDeleted = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Contact>({'isDeleted': false});
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set<RealmList<String>>(
      this,
      'tags',
      RealmList<String>(tags),
    );
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
  }

  Contact._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get businessId =>
      RealmObjectBase.get<String>(this, 'businessId') as String;
  @override
  set businessId(String value) =>
      RealmObjectBase.set(this, 'businessId', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  RealmList<String> get tags =>
      RealmObjectBase.get<String>(this, 'tags') as RealmList<String>;
  @override
  set tags(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<Contact>> get changes =>
      RealmObjectBase.getChanges<Contact>(this);

  @override
  Stream<RealmObjectChanges<Contact>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Contact>(this, keyPaths);

  @override
  Contact freeze() => RealmObjectBase.freezeObject<Contact>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'name': name.toEJson(),
      'type': type.toEJson(),
      'createdAt': createdAt.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'tags': tags.toEJson(),
      'isDeleted': isDeleted.toEJson(),
    };
  }

  static EJsonValue _toEJson(Contact value) => value.toEJson();
  static Contact _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'businessId': EJsonValue businessId,
        'name': EJsonValue name,
        'type': EJsonValue type,
        'createdAt': EJsonValue createdAt,
      } =>
        Contact(
          fromEJson(id),
          fromEJson(businessId),
          fromEJson(name),
          fromEJson(type),
          fromEJson(createdAt),
          phone: fromEJson(ejson['phone']),
          address: fromEJson(ejson['address']),
          tags: fromEJson(ejson['tags']),
          isDeleted: fromEJson(ejson['isDeleted'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Contact._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Contact, 'Contact', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('businessId', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'tags',
        RealmPropertyType.string,
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CashTransaction extends _CashTransaction
    with RealmEntity, RealmObjectBase, RealmObject {
  CashTransaction(
    ObjectId id,
    String businessId,
    double amount,
    String type,
    DateTime date,
    double balanceAfter,
    String status, {
    String? note,
    String? imagePath,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'balanceAfter', balanceAfter);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'imagePath', imagePath);
  }

  CashTransaction._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get businessId =>
      RealmObjectBase.get<String>(this, 'businessId') as String;
  @override
  set businessId(String value) =>
      RealmObjectBase.set(this, 'businessId', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  double get balanceAfter =>
      RealmObjectBase.get<double>(this, 'balanceAfter') as double;
  @override
  set balanceAfter(double value) =>
      RealmObjectBase.set(this, 'balanceAfter', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String? get imagePath =>
      RealmObjectBase.get<String>(this, 'imagePath') as String?;
  @override
  set imagePath(String? value) => RealmObjectBase.set(this, 'imagePath', value);

  @override
  Stream<RealmObjectChanges<CashTransaction>> get changes =>
      RealmObjectBase.getChanges<CashTransaction>(this);

  @override
  Stream<RealmObjectChanges<CashTransaction>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CashTransaction>(this, keyPaths);

  @override
  CashTransaction freeze() =>
      RealmObjectBase.freezeObject<CashTransaction>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'amount': amount.toEJson(),
      'type': type.toEJson(),
      'date': date.toEJson(),
      'balanceAfter': balanceAfter.toEJson(),
      'status': status.toEJson(),
      'note': note.toEJson(),
      'imagePath': imagePath.toEJson(),
    };
  }

  static EJsonValue _toEJson(CashTransaction value) => value.toEJson();
  static CashTransaction _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'businessId': EJsonValue businessId,
        'amount': EJsonValue amount,
        'type': EJsonValue type,
        'date': EJsonValue date,
        'balanceAfter': EJsonValue balanceAfter,
        'status': EJsonValue status,
      } =>
        CashTransaction(
          fromEJson(id),
          fromEJson(businessId),
          fromEJson(amount),
          fromEJson(type),
          fromEJson(date),
          fromEJson(balanceAfter),
          fromEJson(status),
          note: fromEJson(ejson['note']),
          imagePath: fromEJson(ejson['imagePath']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CashTransaction._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CashTransaction,
      'CashTransaction',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('businessId', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('balanceAfter', RealmPropertyType.double),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('imagePath', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class DebtTransaction extends _DebtTransaction
    with RealmEntity, RealmObjectBase, RealmObject {
  DebtTransaction(
    ObjectId id,
    String contactId,
    double amount,
    String type,
    DateTime date,
    double balanceAfter,
    String status, {
    String? note,
    String? imagePath,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'contactId', contactId);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'balanceAfter', balanceAfter);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'imagePath', imagePath);
  }

  DebtTransaction._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get contactId =>
      RealmObjectBase.get<String>(this, 'contactId') as String;
  @override
  set contactId(String value) => RealmObjectBase.set(this, 'contactId', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  double get balanceAfter =>
      RealmObjectBase.get<double>(this, 'balanceAfter') as double;
  @override
  set balanceAfter(double value) =>
      RealmObjectBase.set(this, 'balanceAfter', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String? get imagePath =>
      RealmObjectBase.get<String>(this, 'imagePath') as String?;
  @override
  set imagePath(String? value) => RealmObjectBase.set(this, 'imagePath', value);

  @override
  Stream<RealmObjectChanges<DebtTransaction>> get changes =>
      RealmObjectBase.getChanges<DebtTransaction>(this);

  @override
  Stream<RealmObjectChanges<DebtTransaction>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<DebtTransaction>(this, keyPaths);

  @override
  DebtTransaction freeze() =>
      RealmObjectBase.freezeObject<DebtTransaction>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'contactId': contactId.toEJson(),
      'amount': amount.toEJson(),
      'type': type.toEJson(),
      'date': date.toEJson(),
      'balanceAfter': balanceAfter.toEJson(),
      'status': status.toEJson(),
      'note': note.toEJson(),
      'imagePath': imagePath.toEJson(),
    };
  }

  static EJsonValue _toEJson(DebtTransaction value) => value.toEJson();
  static DebtTransaction _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'contactId': EJsonValue contactId,
        'amount': EJsonValue amount,
        'type': EJsonValue type,
        'date': EJsonValue date,
        'balanceAfter': EJsonValue balanceAfter,
        'status': EJsonValue status,
      } =>
        DebtTransaction(
          fromEJson(id),
          fromEJson(contactId),
          fromEJson(amount),
          fromEJson(type),
          fromEJson(date),
          fromEJson(balanceAfter),
          fromEJson(status),
          note: fromEJson(ejson['note']),
          imagePath: fromEJson(ejson['imagePath']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(DebtTransaction._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      DebtTransaction,
      'DebtTransaction',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('contactId', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('balanceAfter', RealmPropertyType.double),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('imagePath', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Reminder extends _Reminder
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Reminder(
    ObjectId id,
    DateTime dueDate,
    String message, {
    String? contactId,
    bool isDone = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Reminder>({'isDone': false});
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'dueDate', dueDate);
    RealmObjectBase.set(this, 'message', message);
    RealmObjectBase.set(this, 'contactId', contactId);
    RealmObjectBase.set(this, 'isDone', isDone);
  }

  Reminder._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  DateTime get dueDate =>
      RealmObjectBase.get<DateTime>(this, 'dueDate') as DateTime;
  @override
  set dueDate(DateTime value) => RealmObjectBase.set(this, 'dueDate', value);

  @override
  String get message => RealmObjectBase.get<String>(this, 'message') as String;
  @override
  set message(String value) => RealmObjectBase.set(this, 'message', value);

  @override
  String? get contactId =>
      RealmObjectBase.get<String>(this, 'contactId') as String?;
  @override
  set contactId(String? value) => RealmObjectBase.set(this, 'contactId', value);

  @override
  bool get isDone => RealmObjectBase.get<bool>(this, 'isDone') as bool;
  @override
  set isDone(bool value) => RealmObjectBase.set(this, 'isDone', value);

  @override
  Stream<RealmObjectChanges<Reminder>> get changes =>
      RealmObjectBase.getChanges<Reminder>(this);

  @override
  Stream<RealmObjectChanges<Reminder>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Reminder>(this, keyPaths);

  @override
  Reminder freeze() => RealmObjectBase.freezeObject<Reminder>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'dueDate': dueDate.toEJson(),
      'message': message.toEJson(),
      'contactId': contactId.toEJson(),
      'isDone': isDone.toEJson(),
    };
  }

  static EJsonValue _toEJson(Reminder value) => value.toEJson();
  static Reminder _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'dueDate': EJsonValue dueDate,
        'message': EJsonValue message,
      } =>
        Reminder(
          fromEJson(id),
          fromEJson(dueDate),
          fromEJson(message),
          contactId: fromEJson(ejson['contactId']),
          isDone: fromEJson(ejson['isDone'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Reminder._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Reminder, 'Reminder', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('dueDate', RealmPropertyType.timestamp),
      SchemaProperty('message', RealmPropertyType.string),
      SchemaProperty('contactId', RealmPropertyType.string, optional: true),
      SchemaProperty('isDone', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class LinkedCard extends _LinkedCard
    with RealmEntity, RealmObjectBase, RealmObject {
  LinkedCard(
    String id,
    String businessId,
    String last4,
    String brand,
    String expiry,
    String cardholderName,
    String token,
    bool isDefault,
    DateTime addedAt, {
    String? bank,
    double? balance,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'last4', last4);
    RealmObjectBase.set(this, 'brand', brand);
    RealmObjectBase.set(this, 'expiry', expiry);
    RealmObjectBase.set(this, 'cardholderName', cardholderName);
    RealmObjectBase.set(this, 'token', token);
    RealmObjectBase.set(this, 'isDefault', isDefault);
    RealmObjectBase.set(this, 'bank', bank);
    RealmObjectBase.set(this, 'balance', balance);
    RealmObjectBase.set(this, 'addedAt', addedAt);
  }

  LinkedCard._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get businessId =>
      RealmObjectBase.get<String>(this, 'businessId') as String;
  @override
  set businessId(String value) =>
      RealmObjectBase.set(this, 'businessId', value);

  @override
  String get last4 => RealmObjectBase.get<String>(this, 'last4') as String;
  @override
  set last4(String value) => RealmObjectBase.set(this, 'last4', value);

  @override
  String get brand => RealmObjectBase.get<String>(this, 'brand') as String;
  @override
  set brand(String value) => RealmObjectBase.set(this, 'brand', value);

  @override
  String get expiry => RealmObjectBase.get<String>(this, 'expiry') as String;
  @override
  set expiry(String value) => RealmObjectBase.set(this, 'expiry', value);

  @override
  String get cardholderName =>
      RealmObjectBase.get<String>(this, 'cardholderName') as String;
  @override
  set cardholderName(String value) =>
      RealmObjectBase.set(this, 'cardholderName', value);

  @override
  String get token => RealmObjectBase.get<String>(this, 'token') as String;
  @override
  set token(String value) => RealmObjectBase.set(this, 'token', value);

  @override
  bool get isDefault => RealmObjectBase.get<bool>(this, 'isDefault') as bool;
  @override
  set isDefault(bool value) => RealmObjectBase.set(this, 'isDefault', value);

  @override
  String? get bank => RealmObjectBase.get<String>(this, 'bank') as String?;
  @override
  set bank(String? value) => RealmObjectBase.set(this, 'bank', value);

  @override
  double? get balance =>
      RealmObjectBase.get<double>(this, 'balance') as double?;
  @override
  set balance(double? value) => RealmObjectBase.set(this, 'balance', value);

  @override
  DateTime get addedAt =>
      RealmObjectBase.get<DateTime>(this, 'addedAt') as DateTime;
  @override
  set addedAt(DateTime value) => RealmObjectBase.set(this, 'addedAt', value);

  @override
  Stream<RealmObjectChanges<LinkedCard>> get changes =>
      RealmObjectBase.getChanges<LinkedCard>(this);

  @override
  Stream<RealmObjectChanges<LinkedCard>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<LinkedCard>(this, keyPaths);

  @override
  LinkedCard freeze() => RealmObjectBase.freezeObject<LinkedCard>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'last4': last4.toEJson(),
      'brand': brand.toEJson(),
      'expiry': expiry.toEJson(),
      'cardholderName': cardholderName.toEJson(),
      'token': token.toEJson(),
      'isDefault': isDefault.toEJson(),
      'bank': bank.toEJson(),
      'balance': balance.toEJson(),
      'addedAt': addedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(LinkedCard value) => value.toEJson();
  static LinkedCard _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'businessId': EJsonValue businessId,
        'last4': EJsonValue last4,
        'brand': EJsonValue brand,
        'expiry': EJsonValue expiry,
        'cardholderName': EJsonValue cardholderName,
        'token': EJsonValue token,
        'isDefault': EJsonValue isDefault,
        'addedAt': EJsonValue addedAt,
      } =>
        LinkedCard(
          fromEJson(id),
          fromEJson(businessId),
          fromEJson(last4),
          fromEJson(brand),
          fromEJson(expiry),
          fromEJson(cardholderName),
          fromEJson(token),
          fromEJson(isDefault),
          fromEJson(addedAt),
          bank: fromEJson(ejson['bank']),
          balance: fromEJson(ejson['balance']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(LinkedCard._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      LinkedCard,
      'LinkedCard',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('businessId', RealmPropertyType.string),
        SchemaProperty('last4', RealmPropertyType.string),
        SchemaProperty('brand', RealmPropertyType.string),
        SchemaProperty('expiry', RealmPropertyType.string),
        SchemaProperty('cardholderName', RealmPropertyType.string),
        SchemaProperty('token', RealmPropertyType.string),
        SchemaProperty('isDefault', RealmPropertyType.bool),
        SchemaProperty('bank', RealmPropertyType.string, optional: true),
        SchemaProperty('balance', RealmPropertyType.double, optional: true),
        SchemaProperty('addedAt', RealmPropertyType.timestamp),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class WalletTransaction extends _WalletTransaction
    with RealmEntity, RealmObjectBase, RealmObject {
  WalletTransaction(
    String id,
    String businessId,
    String type,
    double amount,
    String provider,
    String destination,
    String destinationType,
    String status,
    DateTime date,
    double balanceAfter, {
    String? reference,
    String? note,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'provider', provider);
    RealmObjectBase.set(this, 'destination', destination);
    RealmObjectBase.set(this, 'destinationType', destinationType);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'reference', reference);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'balanceAfter', balanceAfter);
  }

  WalletTransaction._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get businessId =>
      RealmObjectBase.get<String>(this, 'businessId') as String;
  @override
  set businessId(String value) =>
      RealmObjectBase.set(this, 'businessId', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get provider =>
      RealmObjectBase.get<String>(this, 'provider') as String;
  @override
  set provider(String value) => RealmObjectBase.set(this, 'provider', value);

  @override
  String get destination =>
      RealmObjectBase.get<String>(this, 'destination') as String;
  @override
  set destination(String value) =>
      RealmObjectBase.set(this, 'destination', value);

  @override
  String get destinationType =>
      RealmObjectBase.get<String>(this, 'destinationType') as String;
  @override
  set destinationType(String value) =>
      RealmObjectBase.set(this, 'destinationType', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get reference =>
      RealmObjectBase.get<String>(this, 'reference') as String?;
  @override
  set reference(String? value) => RealmObjectBase.set(this, 'reference', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  double get balanceAfter =>
      RealmObjectBase.get<double>(this, 'balanceAfter') as double;
  @override
  set balanceAfter(double value) =>
      RealmObjectBase.set(this, 'balanceAfter', value);

  @override
  Stream<RealmObjectChanges<WalletTransaction>> get changes =>
      RealmObjectBase.getChanges<WalletTransaction>(this);

  @override
  Stream<RealmObjectChanges<WalletTransaction>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<WalletTransaction>(this, keyPaths);

  @override
  WalletTransaction freeze() =>
      RealmObjectBase.freezeObject<WalletTransaction>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'type': type.toEJson(),
      'amount': amount.toEJson(),
      'provider': provider.toEJson(),
      'destination': destination.toEJson(),
      'destinationType': destinationType.toEJson(),
      'status': status.toEJson(),
      'reference': reference.toEJson(),
      'note': note.toEJson(),
      'date': date.toEJson(),
      'balanceAfter': balanceAfter.toEJson(),
    };
  }

  static EJsonValue _toEJson(WalletTransaction value) => value.toEJson();
  static WalletTransaction _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'businessId': EJsonValue businessId,
        'type': EJsonValue type,
        'amount': EJsonValue amount,
        'provider': EJsonValue provider,
        'destination': EJsonValue destination,
        'destinationType': EJsonValue destinationType,
        'status': EJsonValue status,
        'date': EJsonValue date,
        'balanceAfter': EJsonValue balanceAfter,
      } =>
        WalletTransaction(
          fromEJson(id),
          fromEJson(businessId),
          fromEJson(type),
          fromEJson(amount),
          fromEJson(provider),
          fromEJson(destination),
          fromEJson(destinationType),
          fromEJson(status),
          fromEJson(date),
          fromEJson(balanceAfter),
          reference: fromEJson(ejson['reference']),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(WalletTransaction._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      WalletTransaction,
      'WalletTransaction',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('businessId', RealmPropertyType.string),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('provider', RealmPropertyType.string),
        SchemaProperty('destination', RealmPropertyType.string),
        SchemaProperty('destinationType', RealmPropertyType.string),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty('reference', RealmPropertyType.string, optional: true),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('balanceAfter', RealmPropertyType.double),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Product extends _Product with RealmEntity, RealmObjectBase, RealmObject {
  Product(
    ObjectId id,
    String businessId,
    String name,
    String sku,
    String category,
    double price,
    double cost,
    double stock,
    double minStock,
    DateTime createdAt,
    bool isDeleted, {
    String? unit,
    String? notes,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'sku', sku);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'price', price);
    RealmObjectBase.set(this, 'cost', cost);
    RealmObjectBase.set(this, 'stock', stock);
    RealmObjectBase.set(this, 'minStock', minStock);
    RealmObjectBase.set(this, 'unit', unit);
    RealmObjectBase.set(this, 'notes', notes);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
  }

  Product._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get businessId =>
      RealmObjectBase.get<String>(this, 'businessId') as String;
  @override
  set businessId(String value) =>
      RealmObjectBase.set(this, 'businessId', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get sku => RealmObjectBase.get<String>(this, 'sku') as String;
  @override
  set sku(String value) => RealmObjectBase.set(this, 'sku', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  double get price => RealmObjectBase.get<double>(this, 'price') as double;
  @override
  set price(double value) => RealmObjectBase.set(this, 'price', value);

  @override
  double get cost => RealmObjectBase.get<double>(this, 'cost') as double;
  @override
  set cost(double value) => RealmObjectBase.set(this, 'cost', value);

  @override
  double get stock => RealmObjectBase.get<double>(this, 'stock') as double;
  @override
  set stock(double value) => RealmObjectBase.set(this, 'stock', value);

  @override
  double get minStock =>
      RealmObjectBase.get<double>(this, 'minStock') as double;
  @override
  set minStock(double value) => RealmObjectBase.set(this, 'minStock', value);

  @override
  String? get unit => RealmObjectBase.get<String>(this, 'unit') as String?;
  @override
  set unit(String? value) => RealmObjectBase.set(this, 'unit', value);

  @override
  String? get notes => RealmObjectBase.get<String>(this, 'notes') as String?;
  @override
  set notes(String? value) => RealmObjectBase.set(this, 'notes', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  bool get isDeleted => RealmObjectBase.get<bool>(this, 'isDeleted') as bool;
  @override
  set isDeleted(bool value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  Stream<RealmObjectChanges<Product>> get changes =>
      RealmObjectBase.getChanges<Product>(this);

  @override
  Stream<RealmObjectChanges<Product>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Product>(this, keyPaths);

  @override
  Product freeze() => RealmObjectBase.freezeObject<Product>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'name': name.toEJson(),
      'sku': sku.toEJson(),
      'category': category.toEJson(),
      'price': price.toEJson(),
      'cost': cost.toEJson(),
      'stock': stock.toEJson(),
      'minStock': minStock.toEJson(),
      'unit': unit.toEJson(),
      'notes': notes.toEJson(),
      'createdAt': createdAt.toEJson(),
      'isDeleted': isDeleted.toEJson(),
    };
  }

  static EJsonValue _toEJson(Product value) => value.toEJson();
  static Product _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'businessId': EJsonValue businessId,
        'name': EJsonValue name,
        'sku': EJsonValue sku,
        'category': EJsonValue category,
        'price': EJsonValue price,
        'cost': EJsonValue cost,
        'stock': EJsonValue stock,
        'minStock': EJsonValue minStock,
        'createdAt': EJsonValue createdAt,
        'isDeleted': EJsonValue isDeleted,
      } =>
        Product(
          fromEJson(id),
          fromEJson(businessId),
          fromEJson(name),
          fromEJson(sku),
          fromEJson(category),
          fromEJson(price),
          fromEJson(cost),
          fromEJson(stock),
          fromEJson(minStock),
          fromEJson(createdAt),
          fromEJson(isDeleted),
          unit: fromEJson(ejson['unit']),
          notes: fromEJson(ejson['notes']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Product._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Product, 'Product', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('businessId', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('sku', RealmPropertyType.string),
      SchemaProperty('category', RealmPropertyType.string),
      SchemaProperty('price', RealmPropertyType.double),
      SchemaProperty('cost', RealmPropertyType.double),
      SchemaProperty('stock', RealmPropertyType.double),
      SchemaProperty('minStock', RealmPropertyType.double),
      SchemaProperty('unit', RealmPropertyType.string, optional: true),
      SchemaProperty('notes', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('isDeleted', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StockMovement extends _StockMovement
    with RealmEntity, RealmObjectBase, RealmObject {
  StockMovement(
    ObjectId id,
    String productId,
    String type,
    double quantity,
    double unitPrice,
    DateTime date,
    String status, {
    String? note,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'productId', productId);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'unitPrice', unitPrice);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'status', status);
  }

  StockMovement._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get productId =>
      RealmObjectBase.get<String>(this, 'productId') as String;
  @override
  set productId(String value) => RealmObjectBase.set(this, 'productId', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  double get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double;
  @override
  set quantity(double value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double get unitPrice =>
      RealmObjectBase.get<double>(this, 'unitPrice') as double;
  @override
  set unitPrice(double value) => RealmObjectBase.set(this, 'unitPrice', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  Stream<RealmObjectChanges<StockMovement>> get changes =>
      RealmObjectBase.getChanges<StockMovement>(this);

  @override
  Stream<RealmObjectChanges<StockMovement>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<StockMovement>(this, keyPaths);

  @override
  StockMovement freeze() => RealmObjectBase.freezeObject<StockMovement>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'productId': productId.toEJson(),
      'type': type.toEJson(),
      'quantity': quantity.toEJson(),
      'unitPrice': unitPrice.toEJson(),
      'date': date.toEJson(),
      'note': note.toEJson(),
      'status': status.toEJson(),
    };
  }

  static EJsonValue _toEJson(StockMovement value) => value.toEJson();
  static StockMovement _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'productId': EJsonValue productId,
        'type': EJsonValue type,
        'quantity': EJsonValue quantity,
        'unitPrice': EJsonValue unitPrice,
        'date': EJsonValue date,
        'status': EJsonValue status,
      } =>
        StockMovement(
          fromEJson(id),
          fromEJson(productId),
          fromEJson(type),
          fromEJson(quantity),
          fromEJson(unitPrice),
          fromEJson(date),
          fromEJson(status),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StockMovement._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      StockMovement,
      'StockMovement',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('productId', RealmPropertyType.string),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('quantity', RealmPropertyType.double),
        SchemaProperty('unitPrice', RealmPropertyType.double),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('status', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StaffPayment extends _StaffPayment
    with RealmEntity, RealmObjectBase, RealmObject {
  StaffPayment(
    ObjectId id,
    String staffId,
    double amount,
    String type,
    DateTime date,
    String status, {
    String? note,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'staffId', staffId);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'status', status);
  }

  StaffPayment._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get staffId => RealmObjectBase.get<String>(this, 'staffId') as String;
  @override
  set staffId(String value) => RealmObjectBase.set(this, 'staffId', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  Stream<RealmObjectChanges<StaffPayment>> get changes =>
      RealmObjectBase.getChanges<StaffPayment>(this);

  @override
  Stream<RealmObjectChanges<StaffPayment>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<StaffPayment>(this, keyPaths);

  @override
  StaffPayment freeze() => RealmObjectBase.freezeObject<StaffPayment>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'staffId': staffId.toEJson(),
      'amount': amount.toEJson(),
      'type': type.toEJson(),
      'date': date.toEJson(),
      'note': note.toEJson(),
      'status': status.toEJson(),
    };
  }

  static EJsonValue _toEJson(StaffPayment value) => value.toEJson();
  static StaffPayment _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'staffId': EJsonValue staffId,
        'amount': EJsonValue amount,
        'type': EJsonValue type,
        'date': EJsonValue date,
        'status': EJsonValue status,
      } =>
        StaffPayment(
          fromEJson(id),
          fromEJson(staffId),
          fromEJson(amount),
          fromEJson(type),
          fromEJson(date),
          fromEJson(status),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StaffPayment._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      StaffPayment,
      'StaffPayment',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('staffId', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('status', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class StaffAttendance extends _StaffAttendance
    with RealmEntity, RealmObjectBase, RealmObject {
  StaffAttendance(
    ObjectId id,
    String staffId,
    DateTime date,
    String status, {
    String? note,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'staffId', staffId);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'note', note);
  }

  StaffAttendance._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get staffId => RealmObjectBase.get<String>(this, 'staffId') as String;
  @override
  set staffId(String value) => RealmObjectBase.set(this, 'staffId', value);

  @override
  DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
  @override
  set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  Stream<RealmObjectChanges<StaffAttendance>> get changes =>
      RealmObjectBase.getChanges<StaffAttendance>(this);

  @override
  Stream<RealmObjectChanges<StaffAttendance>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<StaffAttendance>(this, keyPaths);

  @override
  StaffAttendance freeze() =>
      RealmObjectBase.freezeObject<StaffAttendance>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'staffId': staffId.toEJson(),
      'date': date.toEJson(),
      'status': status.toEJson(),
      'note': note.toEJson(),
    };
  }

  static EJsonValue _toEJson(StaffAttendance value) => value.toEJson();
  static StaffAttendance _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'staffId': EJsonValue staffId,
        'date': EJsonValue date,
        'status': EJsonValue status,
      } =>
        StaffAttendance(
          fromEJson(id),
          fromEJson(staffId),
          fromEJson(date),
          fromEJson(status),
          note: fromEJson(ejson['note']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(StaffAttendance._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      StaffAttendance,
      'StaffAttendance',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('staffId', RealmPropertyType.string),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Staff extends _Staff with RealmEntity, RealmObjectBase, RealmObject {
  Staff(
    ObjectId id,
    String businessId,
    String name,
    String role,
    double salary,
    String salaryType,
    DateTime joinDate,
    bool isActive,
    DateTime createdAt, {
    String? phone,
    String? address,
    String? notes,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'role', role);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'salary', salary);
    RealmObjectBase.set(this, 'salaryType', salaryType);
    RealmObjectBase.set(this, 'joinDate', joinDate);
    RealmObjectBase.set(this, 'isActive', isActive);
    RealmObjectBase.set(this, 'notes', notes);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  Staff._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get businessId =>
      RealmObjectBase.get<String>(this, 'businessId') as String;
  @override
  set businessId(String value) =>
      RealmObjectBase.set(this, 'businessId', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get role => RealmObjectBase.get<String>(this, 'role') as String;
  @override
  set role(String value) => RealmObjectBase.set(this, 'role', value);

  @override
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  double get salary => RealmObjectBase.get<double>(this, 'salary') as double;
  @override
  set salary(double value) => RealmObjectBase.set(this, 'salary', value);

  @override
  String get salaryType =>
      RealmObjectBase.get<String>(this, 'salaryType') as String;
  @override
  set salaryType(String value) =>
      RealmObjectBase.set(this, 'salaryType', value);

  @override
  DateTime get joinDate =>
      RealmObjectBase.get<DateTime>(this, 'joinDate') as DateTime;
  @override
  set joinDate(DateTime value) => RealmObjectBase.set(this, 'joinDate', value);

  @override
  bool get isActive => RealmObjectBase.get<bool>(this, 'isActive') as bool;
  @override
  set isActive(bool value) => RealmObjectBase.set(this, 'isActive', value);

  @override
  String? get notes => RealmObjectBase.get<String>(this, 'notes') as String?;
  @override
  set notes(String? value) => RealmObjectBase.set(this, 'notes', value);

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  Stream<RealmObjectChanges<Staff>> get changes =>
      RealmObjectBase.getChanges<Staff>(this);

  @override
  Stream<RealmObjectChanges<Staff>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Staff>(this, keyPaths);

  @override
  Staff freeze() => RealmObjectBase.freezeObject<Staff>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'name': name.toEJson(),
      'role': role.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'salary': salary.toEJson(),
      'salaryType': salaryType.toEJson(),
      'joinDate': joinDate.toEJson(),
      'isActive': isActive.toEJson(),
      'notes': notes.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Staff value) => value.toEJson();
  static Staff _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'businessId': EJsonValue businessId,
        'name': EJsonValue name,
        'role': EJsonValue role,
        'salary': EJsonValue salary,
        'salaryType': EJsonValue salaryType,
        'joinDate': EJsonValue joinDate,
        'isActive': EJsonValue isActive,
        'createdAt': EJsonValue createdAt,
      } =>
        Staff(
          fromEJson(id),
          fromEJson(businessId),
          fromEJson(name),
          fromEJson(role),
          fromEJson(salary),
          fromEJson(salaryType),
          fromEJson(joinDate),
          fromEJson(isActive),
          fromEJson(createdAt),
          phone: fromEJson(ejson['phone']),
          address: fromEJson(ejson['address']),
          notes: fromEJson(ejson['notes']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Staff._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Staff, 'Staff', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('businessId', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('role', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('salary', RealmPropertyType.double),
      SchemaProperty('salaryType', RealmPropertyType.string),
      SchemaProperty('joinDate', RealmPropertyType.timestamp),
      SchemaProperty('isActive', RealmPropertyType.bool),
      SchemaProperty('notes', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
