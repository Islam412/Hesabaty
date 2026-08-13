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
  Business(
    ObjectId id,
    String name,
    DateTime createdAt, {
    String? logoPath,
    String? phone,
    String? address,
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'logoPath', logoPath);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'createdAt', createdAt);
  }

  Business._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get logoPath =>
      RealmObjectBase.get<String>(this, 'logoPath') as String?;
  @override
  set logoPath(String? value) => RealmObjectBase.set(this, 'logoPath', value);

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
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

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
      '_id': id.toEJson(),
      'name': name.toEJson(),
      'logoPath': logoPath.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'createdAt': createdAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Business value) => value.toEJson();
  static Business _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'name': EJsonValue name,
        'createdAt': EJsonValue createdAt,
      } =>
        Business(
          fromEJson(id),
          fromEJson(name),
          fromEJson(createdAt),
          logoPath: fromEJson(ejson['logoPath']),
          phone: fromEJson(ejson['phone']),
          address: fromEJson(ejson['address']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Business._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Business, 'Business', [
      SchemaProperty(
        'id',
        RealmPropertyType.objectid,
        mapTo: '_id',
        primaryKey: true,
      ),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('logoPath', RealmPropertyType.string, optional: true),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
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
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'phone', phone);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set<RealmList<String>>(
      this,
      'tags',
      RealmList<String>(tags),
    );
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
  }

  Contact._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

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
  String? get phone => RealmObjectBase.get<String>(this, 'phone') as String?;
  @override
  set phone(String? value) => RealmObjectBase.set(this, 'phone', value);

  @override
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  RealmList<String> get tags =>
      RealmObjectBase.get<String>(this, 'tags') as RealmList<String>;
  @override
  set tags(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

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
  Stream<RealmObjectChanges<Contact>> get changes =>
      RealmObjectBase.getChanges<Contact>(this);

  @override
  Stream<RealmObjectChanges<Contact>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Contact>(this, keyPaths);

  @override
  Contact freeze() => RealmObjectBase.freezeObject<Contact>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'name': name.toEJson(),
      'phone': phone.toEJson(),
      'address': address.toEJson(),
      'type': type.toEJson(),
      'tags': tags.toEJson(),
      'createdAt': createdAt.toEJson(),
      'isDeleted': isDeleted.toEJson(),
    };
  }

  static EJsonValue _toEJson(Contact value) => value.toEJson();
  static Contact _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
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
      SchemaProperty(
        'id',
        RealmPropertyType.objectid,
        mapTo: '_id',
        primaryKey: true,
      ),
      SchemaProperty('businessId', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('phone', RealmPropertyType.string, optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('type', RealmPropertyType.string),
      SchemaProperty(
        'tags',
        RealmPropertyType.string,
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
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
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'businessId', businessId);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'imagePath', imagePath);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'balanceAfter', balanceAfter);
    RealmObjectBase.set(this, 'status', status);
  }

  CashTransaction._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

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
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String? get imagePath =>
      RealmObjectBase.get<String>(this, 'imagePath') as String?;
  @override
  set imagePath(String? value) => RealmObjectBase.set(this, 'imagePath', value);

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
      '_id': id.toEJson(),
      'businessId': businessId.toEJson(),
      'amount': amount.toEJson(),
      'type': type.toEJson(),
      'note': note.toEJson(),
      'imagePath': imagePath.toEJson(),
      'date': date.toEJson(),
      'balanceAfter': balanceAfter.toEJson(),
      'status': status.toEJson(),
    };
  }

  static EJsonValue _toEJson(CashTransaction value) => value.toEJson();
  static CashTransaction _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
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
        SchemaProperty(
          'id',
          RealmPropertyType.objectid,
          mapTo: '_id',
          primaryKey: true,
        ),
        SchemaProperty('businessId', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('imagePath', RealmPropertyType.string, optional: true),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('balanceAfter', RealmPropertyType.double),
        SchemaProperty('status', RealmPropertyType.string),
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
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'contactId', contactId);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'imagePath', imagePath);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'balanceAfter', balanceAfter);
    RealmObjectBase.set(this, 'status', status);
  }

  DebtTransaction._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

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
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  String? get imagePath =>
      RealmObjectBase.get<String>(this, 'imagePath') as String?;
  @override
  set imagePath(String? value) => RealmObjectBase.set(this, 'imagePath', value);

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
      '_id': id.toEJson(),
      'contactId': contactId.toEJson(),
      'amount': amount.toEJson(),
      'type': type.toEJson(),
      'note': note.toEJson(),
      'imagePath': imagePath.toEJson(),
      'date': date.toEJson(),
      'balanceAfter': balanceAfter.toEJson(),
      'status': status.toEJson(),
    };
  }

  static EJsonValue _toEJson(DebtTransaction value) => value.toEJson();
  static DebtTransaction _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
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
        SchemaProperty(
          'id',
          RealmPropertyType.objectid,
          mapTo: '_id',
          primaryKey: true,
        ),
        SchemaProperty('contactId', RealmPropertyType.string),
        SchemaProperty('amount', RealmPropertyType.double),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty('note', RealmPropertyType.string, optional: true),
        SchemaProperty('imagePath', RealmPropertyType.string, optional: true),
        SchemaProperty('date', RealmPropertyType.timestamp),
        SchemaProperty('balanceAfter', RealmPropertyType.double),
        SchemaProperty('status', RealmPropertyType.string),
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
    String? cashEntryId,
    bool isDone = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Reminder>({'isDone': false});
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'contactId', contactId);
    RealmObjectBase.set(this, 'cashEntryId', cashEntryId);
    RealmObjectBase.set(this, 'dueDate', dueDate);
    RealmObjectBase.set(this, 'message', message);
    RealmObjectBase.set(this, 'isDone', isDone);
  }

  Reminder._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String? get contactId =>
      RealmObjectBase.get<String>(this, 'contactId') as String?;
  @override
  set contactId(String? value) => RealmObjectBase.set(this, 'contactId', value);

  @override
  String? get cashEntryId =>
      RealmObjectBase.get<String>(this, 'cashEntryId') as String?;
  @override
  set cashEntryId(String? value) =>
      RealmObjectBase.set(this, 'cashEntryId', value);

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
      '_id': id.toEJson(),
      'contactId': contactId.toEJson(),
      'cashEntryId': cashEntryId.toEJson(),
      'dueDate': dueDate.toEJson(),
      'message': message.toEJson(),
      'isDone': isDone.toEJson(),
    };
  }

  static EJsonValue _toEJson(Reminder value) => value.toEJson();
  static Reminder _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'dueDate': EJsonValue dueDate,
        'message': EJsonValue message,
      } =>
        Reminder(
          fromEJson(id),
          fromEJson(dueDate),
          fromEJson(message),
          contactId: fromEJson(ejson['contactId']),
          cashEntryId: fromEJson(ejson['cashEntryId']),
          isDone: fromEJson(ejson['isDone'], defaultValue: false),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Reminder._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Reminder, 'Reminder', [
      SchemaProperty(
        'id',
        RealmPropertyType.objectid,
        mapTo: '_id',
        primaryKey: true,
      ),
      SchemaProperty('contactId', RealmPropertyType.string, optional: true),
      SchemaProperty('cashEntryId', RealmPropertyType.string, optional: true),
      SchemaProperty('dueDate', RealmPropertyType.timestamp),
      SchemaProperty('message', RealmPropertyType.string),
      SchemaProperty('isDone', RealmPropertyType.bool),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
