import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/doc_incoming_cash_order.dart';

/// Название таблиц базы данных
const String tableAccumPartnerDebts = '_AccumPartnerDebts';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

/// Поля для базы данных
class ItemAccumPartnerDeptFields {
  static final List<String> values = [
    id,
    idRegistrar,
    uidOrganization,
    uidPartner,
    uidContract,
    uidDoc,
    nameDoc,
    numberDoc,
    dateDoc,
    balance,
    balanceForPayment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id'; // Инкремент
  static const String idRegistrar =
      'idRegistrar'; // Ссылка на регистратор записи
  static const String uidOrganization = 'uidOrganization';
  static const String uidPartner = 'uidPartner';
  static const String uidContract = 'uidContract';
  static const String uidDoc = 'uidDoc';
  static const String nameDoc = 'nameDoc';
  static const String numberDoc = 'numberDoc';
  static const String dateDoc = 'dateDoc';
  static const String balance = 'balance';
  static const String balanceForPayment = 'balanceForPayment';
}

/// Создание таблиц БД
Future createTableAccumPartnerDebts(db) async {
  await db.execute('''
    CREATE TABLE $tableAccumPartnerDebts (    
      ${ItemAccumPartnerDeptFields.id} $idType,
      ${ItemAccumPartnerDeptFields.idRegistrar} $integerType,      
      ${ItemAccumPartnerDeptFields.uidOrganization} $textType,      
      ${ItemAccumPartnerDeptFields.uidPartner} $textType,
      ${ItemAccumPartnerDeptFields.uidContract} $textType,      
      ${ItemAccumPartnerDeptFields.uidDoc} $textType,
      ${ItemAccumPartnerDeptFields.nameDoc} $textType,
      ${ItemAccumPartnerDeptFields.numberDoc} $textType,
      ${ItemAccumPartnerDeptFields.dateDoc} $textType,      
      ${ItemAccumPartnerDeptFields.balance} $realType,
      ${ItemAccumPartnerDeptFields.balanceForPayment} $realType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<AccumPartnerDept> dbCreatePartnerDept(
    AccumPartnerDept accumDeptPartner) async {
  final db = await instance.database;
  final id = await db.insert(tableAccumPartnerDebts, accumDeptPartner.toJson());
  accumDeptPartner.id = id;
  return accumDeptPartner;
}

Future<int> dbUpdatePartnerDept(AccumPartnerDept accumDeptPartner) async {
  final db = await instance.database;
  return db.update(
    tableAccumPartnerDebts,
    accumDeptPartner.toJson(),
    where: '${ItemAccumPartnerDeptFields.id} = ?',
    whereArgs: [accumDeptPartner.id],
  );
}

Future<int> dbDeletePartnerDept(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableAccumPartnerDebts,
    where: '${ItemAccumPartnerDeptFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllPartnerDept() async {
  final db = await instance.database;
  return await db.delete(
    tableAccumPartnerDebts,
  );
}

Future<AccumPartnerDept> dbReadPartnerDept({
  required String uidPartner,
  required String uidContract,
  required String uidDoc,
}) async {
  final db = await instance.database;
  final maps = await db.query(
    tableAccumPartnerDebts,
    columns: ItemAccumPartnerDeptFields.values,
    where: '${ItemAccumPartnerDeptFields.uidPartner} = ? '
        'AND ${ItemAccumPartnerDeptFields.uidContract} = ?'
        'AND ${ItemAccumPartnerDeptFields.uidDoc} = ?',
    whereArgs: [uidPartner, uidContract, uidDoc],
  );

  if (maps.isNotEmpty) {
    return AccumPartnerDept.fromJson(maps.first);
  } else {
    return AccumPartnerDept(); // Пустое значение
  }
}

/// Получение суммы долга по контракту. Измерение: Контракт, Документ
Future<Map> dbReadSumAccumPartnerDeptByContractDoc({
  required String uidContract,
  required String uidDoc,
}) async {
  final db = await instance.database;
  final result = await db.query(
    tableAccumPartnerDebts,
    columns: ItemAccumPartnerDeptFields.values,
    where: '${ItemAccumPartnerDeptFields.uidContract} = ?'
        'AND ${ItemAccumPartnerDeptFields.uidDoc} = ?',
    whereArgs: [uidContract, uidDoc],
  );

  List<AccumPartnerDept> listAccumPartnerDept =
      result.map((json) => AccumPartnerDept.fromJson(json)).toList();

  // Сумируем все записи по отбору, потому что могут быть сторно у документов
  double balance = 0.0;
  double balanceForPayment = 0.0;

  for (var itemList in listAccumPartnerDept) {
    balance = balance + itemList.balance;
    balanceForPayment = balanceForPayment + itemList.balanceForPayment;
  }

  Map mapBalance = {};
  mapBalance['uidContract'] = uidContract;
  mapBalance['uidDoc'] = uidDoc;
  mapBalance['balance'] = balance;
  mapBalance['balanceForPayment'] = balanceForPayment;

  return mapBalance;
}

/// Получение суммы долга по контракту. Измерение: Контракт
Future<Map> dbReadSumAccumPartnerDeptByContract(
    {required String uidContract}) async {
  final db = await instance.database;
  final result = await db.query(
    tableAccumPartnerDebts,
    columns: ItemAccumPartnerDeptFields.values,
    where: '${ItemAccumPartnerDeptFields.uidContract} = ?',
    whereArgs: [uidContract],
  );

  List<AccumPartnerDept> listAccumPartnerDept =
      result.map((json) => AccumPartnerDept.fromJson(json)).toList();

  // Сумируем все записи по отбору, потому что могут быть сторно у документов
  double balance = 0.0;
  double balanceForPayment = 0.0;

  for (var itemList in listAccumPartnerDept) {
    balance = balance + itemList.balance;
    balanceForPayment = balanceForPayment + itemList.balanceForPayment;
  }

  Map mapBalance = {};
  mapBalance['uidContract'] = uidContract;
  mapBalance['balance'] = balance;
  mapBalance['balanceForPayment'] = balanceForPayment;

  return mapBalance;
}

Future<List<AccumPartnerDept>> dbReadAllAccumPartnerDept() async {
  final db = await instance.database;
  const orderBy = '${ItemAccumPartnerDeptFields.balance} ASC';
  final result = await db.query(tableAccumPartnerDebts, orderBy: orderBy);
  return result.map((json) => AccumPartnerDept.fromJson(json)).toList();
}

Future<List<AccumPartnerDept>> dbReadAllAccumPartnerDeptForPayment() async {
  final db = await instance.database;
  final result = await db.query(
    tableAccumPartnerDebts,
    where: '${ItemAccumPartnerDeptFields.balanceForPayment} > ?',
    whereArgs: [0],
  );
  return result.map((json) => AccumPartnerDept.fromJson(json)).toList();
}

Future<List<AccumPartnerDept>> dbReadAccumPartnerDeptByContract(
    {required String uidContract}) async {
  final db = await instance.database;
  final result = await db.query(
    tableAccumPartnerDebts,
    where: '${ItemAccumPartnerDeptFields.uidContract} = ?',
    whereArgs: [uidContract],
  );
  return result.map((json) => AccumPartnerDept.fromJson(json)).toList();
}

Future<bool> dbCreateAccumPartnerDeptsByRegistrar(
    IncomingCashOrder incomingCashOrder) async {
  // Удалим старые записи для текущего регистратора
  final db = await instance.database;
  try {
    db.transaction((txn) async {
      /// Очистка записей регистратора
      await txn.delete(
        tableAccumPartnerDebts,
        where: '${ItemAccumPartnerDeptFields.idRegistrar} = ?',
        whereArgs: [incomingCashOrder.id],
      );

      /// Добавление записей регистратора при отсутствии номера документа и без статуса №3 (в корзину)
      if (incomingCashOrder.numberFrom1C.isEmpty &&
          incomingCashOrder.status != 3 &&
          incomingCashOrder.status != 0 &&
          incomingCashOrder.sum > 0) {

        AccumPartnerDept accumDeptPartner = AccumPartnerDept()
          ..idRegistrar = incomingCashOrder.id
          ..uidOrganization = incomingCashOrder.uidOrganization
          ..uidPartner = incomingCashOrder.uidPartner
          ..uidContract = incomingCashOrder.uidContract
          ..uidDoc = incomingCashOrder.uidParent
          ..nameDoc = incomingCashOrder.nameParent
          ..balanceForPayment = -incomingCashOrder.sum // Сторно
          ..balance = -incomingCashOrder.sum; // Сторно

        await txn.insert(tableAccumPartnerDebts, accumDeptPartner.toJson());
      }
    });
    return true;
  } catch (e) {
    return false;
  }
}
