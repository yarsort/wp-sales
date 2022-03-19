
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';

/// Название таблиц базы данных
const String tableIncomingCashOrder   = '_DocumentIncomingCashOrder';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

/// Поля для базы данных
class IncomingCashOrderFields {
  static final List<String> values = [
    id,
    status,
    date,
    uid,
    uidParent,
    uidOrganization,
    nameOrganization,
    uidPartner,
    namePartner,
    uidContract,
    nameContract,
    uidCurrency,
    nameCurrency,
    uidCashbox,
    nameCashbox,
    sum,
    comment,
    sendYesTo1C,
    sendNoTo1C,
    dateSendingTo1C,
    numberFrom1C,    
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String status = 'status';// 0 - новый, 1 - отправлено, 2 - удален
  static const String date = 'date';// Дата создания заказа
  static const String uid = 'uid';// UID для 1С и связи с ТЧ
  static const String uidParent = 'uidParent';// UID для 1С и связи с главным документом
  static const String uidOrganization = 'uidOrganization';// Ссылка на организацию
  static const String nameOrganization = 'nameOrganization';// Имя организации
  static const String uidPartner = 'uidPartner';// Ссылка на контрагента
  static const String namePartner = 'namePartner';// Имя контрагента
  static const String uidContract = 'uidContract';// Ссылка на договор контрагента
  static const String nameContract = 'nameContract';// Ссылка на договор контрагента
  static const String uidCurrency = 'uidCurrency';// Ссылка на валюту
  static const String nameCurrency = 'nameCurrency';// Наименование валюты
  static const String uidCashbox = 'uidCashbox';// Ссылка на кассу
  static const String nameCashbox = 'nameCashbox';// Наименование кассы
  static const String sum = 'sum';// Сумма документа
  static const String comment = 'comment';// Комментарий
  static const String sendYesTo1C = 'sendYesTo1C'; // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String sendNoTo1C = 'sendNoTo1C';  // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String dateSendingTo1C = 'dateSendingTo1C'; // Дата отправки заказа в 1С из мобильного устройства
  static const String numberFrom1C = 'numberFrom1C';  

}

/// Создание таблиц БД
Future createTableIncomingCashOrder(db) async {

  /// Документ.ПриходныйКассовыйОрдер
  await db.execute('''
    CREATE TABLE $tableIncomingCashOrder (    
      ${IncomingCashOrderFields.id} $idType, 
      ${IncomingCashOrderFields.status} $integerType,
      ${IncomingCashOrderFields.date} $textType,
      ${IncomingCashOrderFields.uid} $textType,
      ${IncomingCashOrderFields.uidParent} $textType,
      ${IncomingCashOrderFields.uidOrganization} $textType,
      ${IncomingCashOrderFields.nameOrganization} $textType,
      ${IncomingCashOrderFields.uidPartner} $textType,
      ${IncomingCashOrderFields.namePartner} $textType,
      ${IncomingCashOrderFields.uidContract} $textType,
      ${IncomingCashOrderFields.nameContract} $textType,  
      ${IncomingCashOrderFields.uidCurrency} $textType,
      ${IncomingCashOrderFields.nameCurrency} $textType,
      ${IncomingCashOrderFields.uidCashbox} $textType,
      ${IncomingCashOrderFields.nameCashbox} $textType,
      ${IncomingCashOrderFields.sum} $realType,
      ${IncomingCashOrderFields.comment} $textType,
      ${IncomingCashOrderFields.sendYesTo1C} $integerType,
      ${IncomingCashOrderFields.sendNoTo1C} $integerType,
      ${IncomingCashOrderFields.dateSendingTo1C} $textType,
      ${IncomingCashOrderFields.numberFrom1C} $textType      
      )
    ''');

}

/// Операции с объектами: CRUD and more
Future<IncomingCashOrder> dbCreateIncomingCashOrder(IncomingCashOrder incomingCashOrder) async {
  final db = await instance.database;
  final id = await db.insert(tableIncomingCashOrder, incomingCashOrder.toJson());
  incomingCashOrder.id = id;
  return incomingCashOrder;
}

Future<int> dbUpdateIncomingCashOrder(IncomingCashOrder incomingCashOrder) async {
  final db = await instance.database;
  return db.update(
    tableIncomingCashOrder,
    incomingCashOrder.toJson(),
    where: '${IncomingCashOrderFields.id} = ?',
    whereArgs: [incomingCashOrder.id],
  );
}

Future<int> dbDeleteIncomingCashOrder(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableIncomingCashOrder,
    where: '${IncomingCashOrderFields.id} = ?',
    whereArgs: [id],
  );
}

Future<IncomingCashOrder> dbReadIncomingCashOrder(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableIncomingCashOrder,
    columns: IncomingCashOrderFields.values,
    where: '${IncomingCashOrderFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return IncomingCashOrder.fromJson(maps.first);
  } else {
    return IncomingCashOrder();
  }
}

Future<List<IncomingCashOrder>> dbReadIncomingCashOrderUIDParent(String uidPartner) async {
  final db = await instance.database;
  final result = await db.query(
    tableIncomingCashOrder,
    columns: IncomingCashOrderFields.values,
    where: '${IncomingCashOrderFields.uidParent} = ?',
    whereArgs: [uidPartner],
  );

  return result.map((json) => IncomingCashOrder.fromJson(json)).toList();
}

Future<IncomingCashOrder> dbReadIncomingCashOrderUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableIncomingCashOrder,
    columns: IncomingCashOrderFields.values,
    where: '${IncomingCashOrderFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return IncomingCashOrder.fromJson(maps.first);
  } else {
    return IncomingCashOrder();
  }
}

Future<List<IncomingCashOrder>> dbReadAllNewIncomingCashOrder() async {
  final db = await instance.database;
  String orderBy = '${IncomingCashOrderFields.date} ASC';
  final result = await db.query(tableIncomingCashOrder,
      where: '${IncomingCashOrderFields.status} = ?',
      whereArgs: [1],
      orderBy: orderBy);

  return result.map((json) => IncomingCashOrder.fromJson(json)).toList();
}

Future<List<IncomingCashOrder>> dbReadAllSendIncomingCashOrder() async {
  final db = await instance.database;
  String orderBy = '${IncomingCashOrderFields.date} ASC';
  final result = await db.query(
      tableIncomingCashOrder,
      where: '${IncomingCashOrderFields.status} = ?',
      whereArgs: [2],
      orderBy: orderBy);

  return result.map((json) => IncomingCashOrder.fromJson(json)).toList();
}

Future<List<IncomingCashOrder>> dbReadAllTrashIncomingCashOrder() async {
  final db = await instance.database;
  String orderBy = '${IncomingCashOrderFields.date} ASC';
  final result = await db.query(
      tableIncomingCashOrder,
      where: '${IncomingCashOrderFields.status} = ?',
      whereArgs: [3],
      orderBy: orderBy);

  return result.map((json) => IncomingCashOrder.fromJson(json)).toList();
}

Future<int> dbGetCountIncomingCashOrder() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableIncomingCashOrder"));
  return result ?? 0;
}

Future<int> dbGetCountNewIncomingCashOrder() async {
  final db = await instance.database;
  final result = await db.query(tableIncomingCashOrder,
      where: '${IncomingCashOrderFields.status} = ?', whereArgs: [0]);
  return result.map((json) => IncomingCashOrder.fromJson(json)).toList().length;
}

Future<int> dbGetCountSendIncomingCashOrder() async {
  final db = await instance.database;
  final result = await db.query(tableIncomingCashOrder,
      where: '${IncomingCashOrderFields.status} = ?', whereArgs: [1]);
  return result.map((json) => IncomingCashOrder.fromJson(json)).toList().length;
}

Future<int> dbGetCountTrashIncomingCashOrder() async {
  final db = await instance.database;
  final result = await db.query(tableIncomingCashOrder,
      where: '${IncomingCashOrderFields.status} = ?', whereArgs: [2]);
  return result.map((json) => IncomingCashOrder.fromJson(json)).toList().length;
}