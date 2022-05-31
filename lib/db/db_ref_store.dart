
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_store.dart';

/// Название таблиц базы данных
const String tableStore   = '_ReferenceStore';

/// Поля для базы данных
class ItemStoreFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidOrganization,
    uidPartner,
    uidContract,
    uidPrice,
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
  static const String uidOrganization = 'uidOrganization';
  static const String uidPartner = 'uidPartner';
  static const String uidContract = 'uidContract';
  static const String uidPrice = 'uidPrice';
  static const String address = 'address';
  static const String comment = 'comment';
  static const String dateEdit = 'dateEdit';
}

/// Создание таблиц БД
Future createTableStore(db) async {

  // Удалим если она существовала до этого
  await db.execute("DROP TABLE IF EXISTS $tableStore");

  await db.execute('''
    CREATE TABLE $tableStore (    
      ${ItemStoreFields.id} $idType,
      ${ItemStoreFields.isGroup} $integerType,      
      ${ItemStoreFields.uid} $textType,
      ${ItemStoreFields.code} $textType,      
      ${ItemStoreFields.name} $textType,      
      ${ItemStoreFields.uidOrganization} $textType,
      ${ItemStoreFields.uidPartner} $textType,
      ${ItemStoreFields.uidContract} $textType,      
      ${ItemStoreFields.uidPrice} $textType,
      ${ItemStoreFields.address} $textType,
      ${ItemStoreFields.comment} $textType,
      ${ItemStoreFields.dateEdit} $textType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<Store> dbCreateStore(Store currency) async {
  final db = await instance.database;
  final id = await db.insert(tableStore, currency.toJson());
  currency.id = id;
  return currency;
}

Future<int> dbUpdateStore(Store price) async {
  final db = await instance.database;
  return db.update(
    tableStore,
    price.toJson(),
    where: '${ItemStoreFields.id} = ?',
    whereArgs: [price.id],
  );
}

Future<int> dbDeleteStore(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableStore,
    where: '${ItemStoreFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllStore() async {
  final db = await instance.database;
  return await db.delete(
    tableStore,
  );
}

Future<Store> dbReadStore(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableStore,
    columns: ItemStoreFields.values,
    where: '${ItemStoreFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Store.fromJson(maps.first);
  } else {
    return Store();
  }
}

Future<Store> dbReadStoreUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableStore,
    columns: ItemStoreFields.values,
    where: '${ItemStoreFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Store.fromJson(maps.first);
  } else {
    return Store();
  }
}

Future<List<Store>> dbReadStoresOfPartner(String uidPartner) async {
  final db = await instance.database;
  const orderBy = '${ItemStoreFields.name} ASC';
  final result = await db.query(
      tableStore,
      where: '${ItemStoreFields.uidPartner} = ?',
      whereArgs: [uidPartner],
      orderBy: orderBy);
  return result.map((json) => Store.fromJson(json)).toList();
}

Future<List<Store>> dbReadAllStore() async {
  final db = await instance.database;
  const orderBy = '${ItemStoreFields.name} ASC';
  final result = await db.query(tableStore, orderBy: orderBy);
  return result.map((json) => Store.fromJson(json)).toList();
}

Future<int> dbGetCountStore() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableStore"));
  return result ?? 0;
}