
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_price.dart';

///***********************************
/// Название таблиц базы данных
///***********************************
const String tablePrice   = '_ReferencePrice';

/// Поля для базы данных
class ItemPriceFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String comment = 'comment';

}

/// Справочник.ТипыЦен
Future<Price> dbCreatePrice(Price price) async {
  final db = await instance.database;
  final id = await db.insert(tablePrice, price.toJson());
  price.id = id;
  return price;
}

Future<int> dbUpdatePrice(Price price) async {
  final db = await instance.database;
  return db.update(
    tablePrice,
    price.toJson(),
    where: '${ItemPriceFields.id} = ?',
    whereArgs: [price.id],
  );
}

Future<int> dbDeletePrice(int id) async {
  final db = await instance.database;
  return await db.delete(
    tablePrice,
    where: '${ItemPriceFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllPrice() async {
  final db = await instance.database;
  return await db.delete(
    tablePrice,
  );
}

Future<Price> dbReadPrice(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tablePrice,
    columns: ItemPriceFields.values,
    where: '${ItemPriceFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Price.fromJson(maps.first);
  } else {
    throw Price();
  }
}

Future<Price> dbReadPriceByUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tablePrice,
    columns: ItemPriceFields.values,
    where: '${ItemPriceFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Price.fromJson(maps.first);
  } else {
    throw Price();
  }
}

Future<List<Price>> dbReadAllPrices() async {
  final db = await instance.database;
  const orderBy = '${ItemPriceFields.name} ASC';
  final result = await db.query(tablePrice, orderBy: orderBy);
  return result.map((json) => Price.fromJson(json)).toList();
}

Future<int> dbGetCountPrice() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tablePrice"));
  return result ?? 0;
}
