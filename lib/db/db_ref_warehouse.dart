
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_warehouse.dart';

/// Название таблиц базы данных
const String tableWarehouse   = '_ReferenceWarehouse';

/// Поля для базы данных
class ItemWarehouseFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    phone,
    address,
    comment,
    dateEdit,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String comment = 'comment';
  static const String dateEdit = 'dateEdit';
}

/// Создание таблиц БД
Future createTableWarehouse(db) async {
  await db.execute('''
    CREATE TABLE $tableWarehouse (    
      ${ItemWarehouseFields.id} $idType,
      ${ItemWarehouseFields.isGroup} $integerType,      
      ${ItemWarehouseFields.uid} $textType,
      ${ItemWarehouseFields.code} $textType,      
      ${ItemWarehouseFields.name} $textType,
      ${ItemWarehouseFields.uidParent} $textType,
      ${ItemWarehouseFields.phone} $textType,
      ${ItemWarehouseFields.address} $textType,      
      ${ItemWarehouseFields.comment} $textType,
      ${ItemWarehouseFields.dateEdit} $textType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<Warehouse> dbCreateWarehouse(Warehouse warehouse) async {
  final db = await instance.database;
  final id = await db.insert(tableWarehouse, warehouse.toJson());
  warehouse.id = id;
  return warehouse;
}

Future<int> dbUpdateWarehouse(Warehouse warehouse) async {
  final db = await instance.database;
  return db.update(
    tableWarehouse,
    warehouse.toJson(),
    where: '${ItemWarehouseFields.id} = ?',
    whereArgs: [warehouse.id],
  );
}

Future<int> dbDeleteWarehouse(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableWarehouse,
    where: '${ItemWarehouseFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllWarehouse() async {
  final db = await instance.database;
  return await db.delete(
    tableWarehouse,
  );
}

Future<Warehouse> dbReadWarehouse(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableWarehouse,
    columns: ItemWarehouseFields.values,
    where: '${ItemWarehouseFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Warehouse.fromJson(maps.first);
  } else {
    return Warehouse();
  }
}

Future<Warehouse> dbReadWarehouseUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableWarehouse,
    columns: ItemWarehouseFields.values,
    where: '${ItemWarehouseFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Warehouse.fromJson(maps.first);
  } else {
    return Warehouse();
  }
}

Future<Warehouse> dbReadWarehouseByUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableWarehouse,
    columns: ItemWarehouseFields.values,
    where: '${ItemWarehouseFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Warehouse.fromJson(maps.first);
  } else {
    return Warehouse();
  }
}

Future<List<Warehouse>> dbReadAllWarehouse() async {
  final db = await instance.database;
  const orderBy = '${ItemWarehouseFields.name} ASC';
  final result = await db.query(tableWarehouse, orderBy: orderBy);
  return result.map((json) => Warehouse.fromJson(json)).toList();
}

Future<int> dbGetCountWarehouse() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableWarehouse"));
  return result ?? 0;
}