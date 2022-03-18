
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_currency.dart';

/// Название таблиц базы данных
const String tableCurrency   = '_ReferenceCurrency';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

/// Поля для базы данных
class ItemCurrencyFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    course,
    multiplicity,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String course = 'course';
  static const String multiplicity = 'multiplicity';
  static const String comment = 'comment';

}

/// Создание таблиц БД
Future createTableCurrency(db) async {
  await db.execute('''
    CREATE TABLE $tableCurrency (    
      ${ItemCurrencyFields.id} $idType,
      ${ItemCurrencyFields.isGroup} $integerType,      
      ${ItemCurrencyFields.uid} $textType,
      ${ItemCurrencyFields.code} $textType,      
      ${ItemCurrencyFields.name} $textType,
      ${ItemCurrencyFields.uidParent} $textType,
      ${ItemCurrencyFields.course} $realType,
      ${ItemCurrencyFields.multiplicity} $realType,
      ${ItemCurrencyFields.comment} $textType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<Currency> dbCreateCurrency(Currency currency) async {
  final db = await instance.database;
  final id = await db.insert(tableCurrency, currency.toJson());
  currency.id = id;
  return currency;
}

Future<int> dbUpdateCurrency(Currency price) async {
  final db = await instance.database;
  return db.update(
    tableCurrency,
    price.toJson(),
    where: '${ItemCurrencyFields.id} = ?',
    whereArgs: [price.id],
  );
}

Future<int> dbDeleteCurrency(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableCurrency,
    where: '${ItemCurrencyFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllCurrency() async {
  final db = await instance.database;
  return await db.delete(
    tableCurrency,
  );
}

Future<Currency> dbReadCurrency(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableCurrency,
    columns: ItemCurrencyFields.values,
    where: '${ItemCurrencyFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Currency.fromJson(maps.first);
  } else {
    return Currency();
  }
}

Future<Currency> dbReadCurrencyUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableCurrency,
    columns: ItemCurrencyFields.values,
    where: '${ItemCurrencyFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Currency.fromJson(maps.first);
  } else {
    return Currency();
  }
}

Future<List<Currency>> dbReadAllCurrency() async {
  final db = await instance.database;
  const orderBy = '${ItemCurrencyFields.name} ASC';
  final result = await db.query(tableCurrency, orderBy: orderBy);
  return result.map((json) => Currency.fromJson(json)).toList();
}

Future<int> dbGetCountCurrency() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableCurrency"));
  return result ?? 0;
}