
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_product.dart';

/// Название таблиц базы данных
const String tableProduct   = '_ReferenceProduct';

/// Поля для базы данных
class ItemProductFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    vendorCode,
    uidParent,
    uidUnit,
    nameUnit,
    barcode,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String vendorCode = 'vendorCode';
  static const String uidParent = 'uidParent';
  static const String uidUnit = 'uidUnit';
  static const String nameUnit = 'nameUnit';
  static const String barcode = 'barcode';
  static const String comment = 'comment';
}

/// Создание таблиц БД
Future createTableProduct(db) async {
  await db.execute('''
    CREATE TABLE $tableProduct (    
      ${ItemProductFields.id} $idType,
      ${ItemProductFields.isGroup} $integerType,      
      ${ItemProductFields.uid} $textType,
      ${ItemProductFields.code} $textType,      
      ${ItemProductFields.name} $textType,
      ${ItemProductFields.vendorCode} $textType,
      ${ItemProductFields.uidParent} $textType,
      ${ItemProductFields.uidUnit} $textType,
      ${ItemProductFields.nameUnit} $textType,
      ${ItemProductFields.barcode} $textType,      
      ${ItemProductFields.comment} $textType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<Product> dbCreateProduct(Product product) async {
  final db = await instance.database;
  final id = await db.insert(tableProduct, product.toJson());
  product.id = id;
  return product;
}

Future<int> dbUpdateProduct(Product product) async {
  final db = await instance.database;
  return db.update(
    tableProduct,
    product.toJson(),
    where: '${ItemProductFields.id} = ?',
    whereArgs: [product.id],
  );
}

Future<int> dbDeleteProduct(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableProduct,
    where: '${ItemProductFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllProduct() async {
  final db = await instance.database;
  return await db.delete(
    tableProduct,
  );
}

Future<Product> dbReadProduct(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableProduct,
    columns: ItemProductFields.values,
    where: '${ItemProductFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Product.fromJson(maps.first);
  } else {
    return Product();
  }
}

Future<Product> dbReadProductUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableProduct,
    columns: ItemProductFields.values,
    where: '${ItemProductFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Product.fromJson(maps.first);
  } else {
    return Product();
  }
}

Future<Product> dbReadProductByBarcode(String barcode) async {
  final db = await instance.database;
  final maps = await db.query(
    tableProduct,
    columns: ItemProductFields.values,
    where: '${ItemProductFields.barcode} = ?',
    whereArgs: [barcode],
  );

  if (maps.isNotEmpty) {
    return Product.fromJson(maps.first);
  } else {
    return Product();
  }
}

Future<List<Product>> dbReadAllProducts() async {
  final db = await instance.database;
  const orderBy = '${ItemProductFields.name} ASC';
  final result = await db.query(tableProduct, orderBy: orderBy);
  return result.map((json) => Product.fromJson(json)).toList();
}

Future<List<Product>> dbReadProductsByParent(String uidParent) async {
  final db = await instance.database;
  const orderBy = '${ItemProductFields.name} ASC';
  final result = await db.query(tableProduct,
      where: '${ItemProductFields.uidParent} = ?',
      whereArgs: [uidParent],
      orderBy: orderBy);
  return result.map((json) => Product.fromJson(json)).toList();
}

Future<List<Product>> dbReadProductsForSearch(String searchString) async {
  final db = await instance.database;
  const orderBy = '${ItemProductFields.name} ASC';
  final result = await db.query(tableProduct,
      where: 'LOWER(${ItemProductFields.name}) LIKE LOWER(?)',
      whereArgs: ['%$searchString%'],
      orderBy: orderBy);
  return result.map((json) => Product.fromJson(json)).toList();
}

Future<int> dbGetCountProduct() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableProduct"));
  return result ?? 0;
}