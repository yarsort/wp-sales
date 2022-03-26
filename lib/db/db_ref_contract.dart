
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'init_db.dart';

/// Название таблиц базы данных
const String tableContract   = '_ReferenceContract';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

/// Поля для базы данных
class ItemContractFields {
  static final List<String> values = [
    id,                // Инкремент
    isGroup,           // Пометка удаления
    uid,               // UID для 1С и связи с ТЧ
    code,              // Код для 1С
    name,              // Имя партнера
    uidParent,         // Ссылка на группу
    balance,           // Баланс
    balanceForPayment, // Баланс к оплате
    phone,             // Контакты
    address,           // Адрес
    comment,           // Коммментарий
    uidOrganization,   // Имя организации
    namePartner,       // Имя партнера
    uidPartner,        // Ссылка на партнера
    uidPrice,          // Ссылка тип цены
    namePrice,         // Имя типа цены
    uidCurrency,       // Ссылка валюты
    nameCurrency,      // Имя валюты
    schedulePayment,   // Отсрочка платежа
    visitDayOfWeek,    // Дни недели посещения менеджером: 1234567
    visitDayOfMonth,   // Дни месяца посещения менеджером: 1-31(30,28,27)
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';
  static const String isGroup = 'isGroup';
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String balance = 'balance';
  static const String balanceForPayment = 'balanceForPayment';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String comment = 'comment';
  static const String uidOrganization = 'uidOrganization';
  static const String namePartner = 'namePartner';
  static const String uidPartner = 'uidPartner';
  static const String uidPrice = 'uidPrice';
  static const String namePrice = 'namePrice';
  static const String uidCurrency = 'uidCurrency';
  static const String nameCurrency = 'nameCurrency';
  static const String schedulePayment = 'schedulePayment';
  static const String visitDayOfWeek = 'visitDayOfWeek';
  static const String visitDayOfMonth = 'visitDayOfMonth';
}

/// Создание таблиц БД
Future createTableContract(db) async {
  await db.execute('''
    CREATE TABLE $tableContract (
      ${ItemContractFields.id} $idType,
      ${ItemContractFields.isGroup} $integerType,
      ${ItemContractFields.uid} $textType,
      ${ItemContractFields.code} $textType,
      ${ItemContractFields.name} $textType,
      ${ItemContractFields.uidParent} $textType,
      ${ItemContractFields.balance} $realType,
      ${ItemContractFields.balanceForPayment} $realType,
      ${ItemContractFields.phone} $textType,
      ${ItemContractFields.address} $textType,
      ${ItemContractFields.comment} $textType,
      ${ItemContractFields.uidOrganization} $textType,
      ${ItemContractFields.namePartner} $textType,
      ${ItemContractFields.uidPartner} $textType,
      ${ItemContractFields.uidPrice} $textType,
      ${ItemContractFields.namePrice} $textType,
      ${ItemContractFields.uidCurrency} $textType,
      ${ItemContractFields.nameCurrency} $textType,
      ${ItemContractFields.schedulePayment} $integerType,
      ${ItemContractFields.visitDayOfWeek} $textType,
      ${ItemContractFields.visitDayOfMonth} $textType
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<Contract> dbCreateContract(Contract contract) async {
  final db = await instance.database;
  final id = await db.insert(tableContract, contract.toJson());
  contract.id = id;
  return contract;
}

Future<int> dbUpdateContract(Contract contract) async {
  final db = await instance.database;
  return db.update(
    tableContract,
    contract.toJson(),
    where: '${ItemContractFields.id} = ?',
    whereArgs: [contract.id],
  );
}

Future<int> dbDeleteContract(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableContract,
    where: '${ItemContractFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllContract() async {
  final db = await instance.database;
  return await db.delete(
    tableContract,
  );
}

Future<Contract> dbReadContract(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableContract,
    columns: ItemContractFields.values,
    where: '${ItemContractFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Contract.fromJson(maps.first);
  } else {
    return Contract();
  }
}

Future<Contract> dbReadContractUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableContract,
    columns: ItemContractFields.values,
    where: '${ItemContractFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Contract.fromJson(maps.first);
  } else {
    return Contract();
  }
}

Future<List<Contract>> dbReadContractsOfPartner(String uidPartner) async {
  final db = await instance.database;
  const orderBy = '${ItemContractFields.name} ASC';
  final result = await db.query(
      tableContract,
      where: '${ItemContractFields.uidPartner} = ?',
      whereArgs: [uidPartner],
      orderBy: orderBy);
  return result.map((json) => Contract.fromJson(json)).toList();
}

Future<List<Contract>> dbReadAllContracts() async {
  final db = await instance.database;
  const orderBy = '${ItemContractFields.name} ASC';
  final result = await db.query(tableContract, orderBy: orderBy);
  return result.map((json) => Contract.fromJson(json)).toList();
}

Future<List<Contract>> dbReadForPaymentContracts({int limit = 10}) async {
  final db = await instance.database;
  const orderBy = '${ItemContractFields.balanceForPayment} ASC';
  final result =
  await db.query(tableContract, limit: limit, orderBy: orderBy);
  return result.map((json) => Contract.fromJson(json)).toList();
}

Future<int> dbGetCountContract() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableContract"));
  return result ?? 0;
}