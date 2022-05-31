
import 'package:flutter/material.dart';
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
    nameForSearch,
    vendorCode,
    uidParent,
    uidUnit,
    nameUnit,
    uidProductGroup,
    nameProductGroup,
    barcode,
    comment,
    dateEdit,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String nameForSearch = 'nameForSearch';
  static const String vendorCode = 'vendorCode';
  static const String uidParent = 'uidParent';
  static const String uidUnit = 'uidUnit';
  static const String nameUnit = 'nameUnit';

  // Номенклатурная группа
  static const String uidProductGroup = 'uidProductGroup';
  static const String nameProductGroup = 'nameProductGroup';

  static const String barcode = 'barcode';
  static const String comment = 'comment';
  static const String dateEdit = 'dateEdit';
}

/// Создание таблиц БД
Future createTableProductV1(db) async {

  // Удалим если она существовала до этого
  await db.execute("DROP TABLE IF EXISTS $tableProduct");

  await db.execute('''
    CREATE TABLE $tableProduct (    
      ${ItemProductFields.id} $idType,
      ${ItemProductFields.isGroup} $integerType,      
      ${ItemProductFields.uid} $textType,
      ${ItemProductFields.code} $textType,      
      ${ItemProductFields.name} $textType,
      ${ItemProductFields.nameForSearch} $textType,
      ${ItemProductFields.vendorCode} $textType,
      ${ItemProductFields.uidParent} $textType,
      ${ItemProductFields.uidUnit} $textType,
      ${ItemProductFields.nameUnit} $textType,
      ${ItemProductFields.uidProductGroup} $textType,
      ${ItemProductFields.nameProductGroup} $textType,
      ${ItemProductFields.barcode} $textType,      
      ${ItemProductFields.comment} $textType,
      ${ItemProductFields.dateEdit} $textType            
      )
    ''');
}

/// Создание таблиц БД с новыми колонками
Future createTableProductV2(db) async {
  List<Product> listProducts = [];
  
  // Прочитаем все данные таблицы
  final result = await db.query(tableProduct);
  var list = result.map((json) => Product.fromJson(json)).toList();

  for (var item in list) {
    listProducts.add(item);
  }

  debugPrint('Переход версии. В формате JSON получен состав таблицы: $tableProduct');

  // Удалим таблицу
  await db.execute('DROP TABLE IF EXISTS $tableProduct');
  debugPrint('Переход версии. Удалена таблица: $tableProduct');

  // Добавим таблицу с новыми колонками
  await db.execute('''
    CREATE TABLE $tableProduct (    
      ${ItemProductFields.id} $idType,
      ${ItemProductFields.isGroup} $integerType,      
      ${ItemProductFields.uid} $textType,
      ${ItemProductFields.code} $textType,      
      ${ItemProductFields.name} $textType,
      ${ItemProductFields.nameForSearch} $textType,
      ${ItemProductFields.vendorCode} $textType,
      ${ItemProductFields.uidParent} $textType,
      ${ItemProductFields.uidUnit} $textType,
      ${ItemProductFields.nameUnit} $textType,
      ${ItemProductFields.uidProductGroup} $textType,
      ${ItemProductFields.nameProductGroup} $textType,
      ${ItemProductFields.barcode} $textType,      
      ${ItemProductFields.comment} $textType,
      ${ItemProductFields.dateEdit} $textType            
      )
    ''');
  debugPrint('Переход версии. Создана новая таблица: $tableProduct');

  // Добавим данные в новую таблицу
  for (var itemList in listProducts) {
    await db.insert(tableProduct, itemList.toJson());
  }
  debugPrint('Переход версии. Из формата JSON записан состав таблицы: $tableProduct');
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

Future<List<Product>> dbReadAllProductsBySearch(searchValue) async {
  final db = await instance.database;
  const orderBy = '${ItemProductFields.nameForSearch} ASC';
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
      where: '${ItemProductFields.nameForSearch} LIKE ?',
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