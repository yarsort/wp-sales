
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/doc_return_order_customer.dart';

/// Название таблиц базы данных
const String tableReturnOrderCustomer   = '_DocumentReturnOrderCustomer';
const String tableItemsReturnOrderCustomer   = '_DocumentReturnOrderCustomer_VT1'; // Товары

/// Поля для базы данных
class ReturnOrderCustomerFields {
  static final List<String> values = [
    id,
    status,
    date,
    uid,
    uidParent,
    nameParent,
    uidSettlementDocument,
    nameSettlementDocument,
    uidOrganization,
    nameOrganization,
    uidPartner,
    namePartner,
    uidContract,
    nameContract,
    uidPrice,
    namePrice,
    uidWarehouse,
    nameWarehouse,
    uidCurrency,
    nameCurrency,
    sum,
    comment,
    coordinates,
    dateSending,
    datePaying,
    sendYesTo1C,
    sendNoTo1C,
    dateSendingTo1C,
    numberFrom1C,
    countItems,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String status = 'status';// 0 - новый, 1 - отправлено, 2 - удален
  static const String date = 'date';// Дата создания заказа
  static const String uid = 'uid';// UID для 1С и связи с ТЧ
  static const String uidParent = 'uidParent';// UID для 1С и связи с главным документом
  static const String nameParent = 'nameParent';// Имя главного документа
  static const String uidSettlementDocument = 'uidSettlementDocument'; // UID документа расчета
  static const String nameSettlementDocument = 'nameSettlementDocument'; // Имя документа расчета
  static const String uidOrganization = 'uidOrganization';// Ссылка на организацию
  static const String nameOrganization = 'nameOrganization';// Имя организации
  static const String uidPartner = 'uidPartner';// Ссылка на контрагента
  static const String namePartner = 'namePartner';// Имя контрагента
  static const String uidContract = 'uidContract';// Ссылка на договор контрагента
  static const String nameContract = 'nameContract';// Ссылка на договор контрагента
  static const String uidPrice = 'uidPrice';// Ссылка на тип цены номенклатуры продажи контрагенту
  static const String namePrice = 'namePrice';// Наименование типа цены номенклатуры продажи контрагенту
  static const String uidWarehouse = 'uidWarehouse';// Ссылка на склад
  static const String nameWarehouse = 'nameWarehouse';// Наименование склада
  static const String uidCurrency = 'uidCurrency';// Ссылка на валюту
  static const String nameCurrency = 'nameCurrency';// Наименование валюты
  static const String sum = 'sum';// Сумма документа
  static const String comment = 'comment';// Комментарий
  static const String coordinates = 'coordinates';// Координаты
  static const String dateSending = 'dateSending';// Дата планируемой отгрузки заказа
  static const String datePaying = 'datePaying';// Дата планируемой оплаты заказа
  static const String sendYesTo1C = 'sendYesTo1C'; // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String sendNoTo1C = 'sendNoTo1C';  // Булево: "Отправлено в 1С" - для фильтрации в списках
  static const String dateSendingTo1C = 'dateSendingTo1C'; // Дата отправки заказа в 1С из мобильного устройства
  static const String numberFrom1C = 'numberFrom1C';
  static const String countItems = 'countItems';
}

/// Поля для базы данных
class ItemReturnOrderCustomerFields {
  static final List<String> values = [
    id,
    idReturnOrderCustomer,
    uid,
    name,
    uidUnit,
    nameUnit,
    count,
    price,
    discount,
    sum,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String idReturnOrderCustomer = 'idReturnOrderCustomer'; // Ссылка на документ
  static const String uid = 'uid'; // Ссылка на товар
  static const String name = 'name'; // Имя товара
  static const String uidUnit = 'uidUnit'; // Ссылка на ед. изм.
  static const String nameUnit = 'nameUnit';
  static const String count = 'count';
  static const String price = 'price';
  static const String discount = 'discount';
  static const String sum = 'sum';

}

/// Создание таблиц БД
Future createTableReturnOrderCustomer(db) async {

  // Удалим если она существовала до этого
  await db.execute("DROP TABLE IF EXISTS $tableReturnOrderCustomer");

  /// Документ.ВозвратТоваровОтПокупателя
  await db.execute('''
    CREATE TABLE $tableReturnOrderCustomer (    
      ${ReturnOrderCustomerFields.id} $idType, 
      ${ReturnOrderCustomerFields.status} $integerType,
      ${ReturnOrderCustomerFields.date} $textType,
      ${ReturnOrderCustomerFields.uid} $textType,
      ${ReturnOrderCustomerFields.uidParent} $textType,
      ${ReturnOrderCustomerFields.nameParent} $textType,
      ${ReturnOrderCustomerFields.uidSettlementDocument} $textType,
      ${ReturnOrderCustomerFields.nameSettlementDocument} $textType,      
      ${ReturnOrderCustomerFields.uidOrganization} $textType,
      ${ReturnOrderCustomerFields.nameOrganization} $textType,
      ${ReturnOrderCustomerFields.uidPartner} $textType,
      ${ReturnOrderCustomerFields.namePartner} $textType,
      ${ReturnOrderCustomerFields.uidContract} $textType,
      ${ReturnOrderCustomerFields.nameContract} $textType,  
      ${ReturnOrderCustomerFields.uidPrice} $textType,
      ${ReturnOrderCustomerFields.namePrice} $textType,
      ${ReturnOrderCustomerFields.uidWarehouse} $textType,
      ${ReturnOrderCustomerFields.nameWarehouse} $textType,
      ${ReturnOrderCustomerFields.uidCurrency} $textType,
      ${ReturnOrderCustomerFields.nameCurrency} $textType,
      ${ReturnOrderCustomerFields.sum} $realType,
      ${ReturnOrderCustomerFields.comment} $textType,
      ${ReturnOrderCustomerFields.coordinates} $textType,
      ${ReturnOrderCustomerFields.dateSending} $textType,
      ${ReturnOrderCustomerFields.datePaying} $textType,
      ${ReturnOrderCustomerFields.sendYesTo1C} $integerType,
      ${ReturnOrderCustomerFields.sendNoTo1C} $integerType,
      ${ReturnOrderCustomerFields.dateSendingTo1C} $textType,
      ${ReturnOrderCustomerFields.numberFrom1C} $textType,
      ${ReturnOrderCustomerFields.countItems} $integerType
      )
    ''');

}

Future createTableItemReturnOrderCustomer(db) async {

  await db.execute('''
    CREATE TABLE $tableItemsReturnOrderCustomer (    
      ${ItemReturnOrderCustomerFields.id} $idType,
      ${ItemReturnOrderCustomerFields.idReturnOrderCustomer} $integerType,      
      ${ItemReturnOrderCustomerFields.uid} $textType,
      ${ItemReturnOrderCustomerFields.name} $textType,      
      ${ItemReturnOrderCustomerFields.uidUnit} $textType,
      ${ItemReturnOrderCustomerFields.nameUnit} $textType,
      ${ItemReturnOrderCustomerFields.count} $realType,
      ${ItemReturnOrderCustomerFields.price} $realType,
      ${ItemReturnOrderCustomerFields.discount} $realType,
      ${ItemReturnOrderCustomerFields.sum} $realType      
      )
    ''');

}

/// Операции с объектами: CRUD and more
Future<ReturnOrderCustomer> dbCreateReturnOrderCustomer(ReturnOrderCustomer returnOrderCustomer,
    List<ItemReturnOrderCustomer> itemsReturnOrderCustomer) async {
  final db = await instance.database;
  try {
    await db.transaction((txn) async {
      returnOrderCustomer.id = await txn.insert(tableReturnOrderCustomer, returnOrderCustomer.toJson());

      /// Запись ТЧ "Товары"
      for (var itemReturnOrderCustomer in itemsReturnOrderCustomer) {
        itemReturnOrderCustomer.idReturnOrderCustomer = returnOrderCustomer.id;
        await txn.insert(tableItemsReturnOrderCustomer, itemReturnOrderCustomer.toJson());
      }
    });
    return returnOrderCustomer;
  } catch (e) {
    throw Exception('Ошибка записи объекта!');
  }
}

Future<int> dbUpdateReturnOrderCustomer(ReturnOrderCustomer returnOrderCustomer, List<ItemReturnOrderCustomer> itemsReturnOrderCustomer) async {
  final db = await instance.database;
  int intOperation = 0;
  try {
    await db.transaction((txn) async {
      intOperation = intOperation +
          await txn.update(
            tableReturnOrderCustomer,
            returnOrderCustomer.toJson(),
            where: '${ReturnOrderCustomerFields.id} = ?',
            whereArgs: [returnOrderCustomer.id],
          );

      /// Очистка ТЧ "Товары"
      txn.delete(
        tableItemsReturnOrderCustomer,
        where: '${ItemReturnOrderCustomerFields.idReturnOrderCustomer} = ?',
        whereArgs: [returnOrderCustomer.id],
      );
      intOperation = intOperation + 1;

      /// Добавление ТЧ "Товары"
      for (var itemReturnOrderCustomer in itemsReturnOrderCustomer) {
        itemReturnOrderCustomer.idReturnOrderCustomer = returnOrderCustomer.id;
        txn.insert(tableItemsReturnOrderCustomer, itemReturnOrderCustomer.toJson());
        intOperation = intOperation + 1;
      }
    });
    return intOperation;
  } catch (e) {
    throw Exception('Ошибка записи объекта!');
  }
}

Future<int> dbUpdateReturnOrderCustomerWithoutItems(ReturnOrderCustomer returnOrderCustomer) async {
  final db = await instance.database;
  try {
    await db.update(
      tableReturnOrderCustomer,
      returnOrderCustomer.toJson(),
      where: '${ReturnOrderCustomerFields.id} = ?',
      whereArgs: [returnOrderCustomer.id],
    );
    return returnOrderCustomer.id;
  } catch (e) {
    throw Exception('Ошибка записи объекта!');
  }
}

Future<int> dbDeleteReturnOrderCustomer(int id) async {
  final db = await instance.database;
  try {
    await db.transaction((txn) async {
      txn.delete(
        tableReturnOrderCustomer,
        where: '${ReturnOrderCustomerFields.id} = ?',
        whereArgs: [id],
      );
      txn.delete(
        tableItemsReturnOrderCustomer,
        where: '${ItemReturnOrderCustomerFields.idReturnOrderCustomer} = ?',
        whereArgs: [id],
      );
    });
    return 1;
  } catch (e) {
    throw Exception('Ошибка удаления объекта с ID: $id!');
  }
}

Future<ReturnOrderCustomer> dbReadReturnOrderCustomer(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableReturnOrderCustomer,
    columns: ReturnOrderCustomerFields.values,
    where: '${ReturnOrderCustomerFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return ReturnOrderCustomer.fromJson(maps.first);
  } else {
    return ReturnOrderCustomer();
  }
}

Future<List<ReturnOrderCustomer>> dbReadReturnOrderCustomerUIDParent(String uidParent) async {
  final db = await instance.database;
  final result = await db.query(
    tableReturnOrderCustomer,
    columns: ReturnOrderCustomerFields.values,
    where: '${ReturnOrderCustomerFields.uidParent} = ?',
    whereArgs: [uidParent],
  );

  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
}

Future<ReturnOrderCustomer> dbReadReturnOrderCustomerUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableReturnOrderCustomer,
    columns: ReturnOrderCustomerFields.values,
    where: '${ReturnOrderCustomerFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return ReturnOrderCustomer.fromJson(maps.first);
  } else {
    return ReturnOrderCustomer();
  }
}

Future<List<ItemReturnOrderCustomer>> dbReadItemsReturnOrderCustomer(int idReturnOrderCustomer) async {
  final db = await instance.database;
  const orderBy = '${ItemReturnOrderCustomerFields.name} ASC';
  final result = await db.query(tableItemsReturnOrderCustomer,
      where: '${ItemReturnOrderCustomerFields.idReturnOrderCustomer} = ?',
      whereArgs: [idReturnOrderCustomer],
      orderBy: orderBy);

  return result.map((json) => ItemReturnOrderCustomer.fromJson(json)).toList();
}

Future<List<ReturnOrderCustomer>> dbReadAllNewReturnOrderCustomer() async {
  final db = await instance.database;
  String orderBy = '${ReturnOrderCustomerFields.date} DESC';
  final result = await db.query(
      tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ?',
      whereArgs: [1],
      orderBy: orderBy);

  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
}

Future<List<ReturnOrderCustomer>> dbReadAllSendReturnOrderCustomer() async {
  final db = await instance.database;
  String orderBy = '${ReturnOrderCustomerFields.date} DESC';
  final result = await db.query(
      tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ?',
      whereArgs: [2],
      orderBy: orderBy);

  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
}

Future<List<ReturnOrderCustomer>> dbReadAllTrashReturnOrderCustomer() async {
  final db = await instance.database;
  String orderBy = '${ReturnOrderCustomerFields.date} DESC';
  final result = await db.query(
      tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ?',
      whereArgs: [3],
      orderBy: orderBy);

  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
}

Future<int> dbGetCountReturnOrderCustomer() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableReturnOrderCustomer"));
  return result ?? 0;
}

Future<int> dbGetCountNewReturnOrderCustomer() async {
  final db = await instance.database;
  final result = await db.query(tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ?', whereArgs: [1]);
  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList().length;
}

Future<int> dbGetCountSendReturnOrderCustomer() async {
  final db = await instance.database;
  final result = await db.query(tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ?', whereArgs: [2]);
  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList().length;
}

Future<int> dbGetCountTrashReturnOrderCustomer() async {
  final db = await instance.database;
  final result = await db.query(tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ?', whereArgs: [3]);
  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList().length;
}

Future<List<ReturnOrderCustomer>> dbReadAllSendReturnOrderCustomerWithoutNumbers() async {
  final db = await instance.database;
  String orderBy = '${ReturnOrderCustomerFields.date} DESC';
  final result = await db.query(
      tableReturnOrderCustomer,
      where: '${ReturnOrderCustomerFields.status} = ? AND ${ReturnOrderCustomerFields.numberFrom1C} = ?',
      whereArgs: [2, ''],
      orderBy: orderBy);

  return result.map((json) => ReturnOrderCustomer.fromJson(json)).toList();
}