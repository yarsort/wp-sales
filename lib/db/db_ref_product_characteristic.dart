
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_product_characteristic.dart';

/// Название таблиц базы данных
const String tableProductCharacteristic   = '_ReferenceProductCharacteristic';

/// Поля для базы данных
class ItemProductCharacteristicFields {
  static final List<String> values = [
    id,
    uid,
    code,
    name,
    uidProduct,
    comment,
    dateEdit,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidProduct = 'uidProduct';
  static const String comment = 'comment';
  static const String dateEdit = 'dateEdit';
}

/// Создание таблиц БД
Future createTableProductCharacteristic(db) async {
  await db.execute('''
    CREATE TABLE $tableProductCharacteristic (    
      ${ItemProductCharacteristicFields.id} $idType,     
      ${ItemProductCharacteristicFields.uid} $textType,
      ${ItemProductCharacteristicFields.code} $textType,      
      ${ItemProductCharacteristicFields.name} $textType,
      ${ItemProductCharacteristicFields.uidProduct} $textType, 
      ${ItemProductCharacteristicFields.comment} $textType,
      ${ItemProductCharacteristicFields.dateEdit} $textType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<ProductCharacteristic> dbCreateProductCharacteristic(ProductCharacteristic productCharacteristic) async {
  final db = await instance.database;
  final id = await db.insert(
      tableProductCharacteristic,
      productCharacteristic.toJson());
  productCharacteristic.id = id;
  return productCharacteristic;
}

Future<int> dbUpdateProductCharacteristic(ProductCharacteristic productCharacteristic) async {
  final db = await instance.database;
  return db.update(
    tableProductCharacteristic,
    productCharacteristic.toJson(),
    where: '${ItemProductCharacteristicFields.id} = ?',
    whereArgs: [productCharacteristic.id],
  );
}

Future<int> dbDeleteProductCharacteristic(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableProductCharacteristic,
    where: '${ItemProductCharacteristicFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllProductCharacteristic() async {
  final db = await instance.database;
  return await db.delete(
    tableProductCharacteristic,
  );
}

Future<ProductCharacteristic> dbReadProductCharacteristic(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableProductCharacteristic,
    columns: ItemProductCharacteristicFields.values,
    where: '${ItemProductCharacteristicFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return ProductCharacteristic.fromJson(maps.first);
  } else {
    return ProductCharacteristic();
  }
}

Future<ProductCharacteristic> dbReadProductCharacteristicUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableProductCharacteristic,
    columns: ItemProductCharacteristicFields.values,
    where: '${ItemProductCharacteristicFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return ProductCharacteristic.fromJson(maps.first);
  } else {
    return ProductCharacteristic();
  }
}

Future<List<ProductCharacteristic>> dbReadAllProductCharacteristics() async {
  final db = await instance.database;
  const orderBy = '${ItemProductCharacteristicFields.name} ASC';
  final result = await db.query(
      tableProductCharacteristic,
      orderBy: orderBy);
  return result.map((json) => ProductCharacteristic.fromJson(json)).toList();
}

Future<int> dbGetCountProductCharacteristic() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableProductCharacteristic"));
  return result ?? 0;
}