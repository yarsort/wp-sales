
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/accum_product_rests.dart';

/// Название таблиц базы данных
const String tableAccumProductRests   = '_AccumProductRests';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

/// Поля для базы данных
class ItemAccumProductRestsFields {
  static final List<String> values = [
    id,
    idRegistrar,
    uidWarehouse,
    uidProduct,
    uidProductCharacteristic,
    uidUnit,
    count,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String idRegistrar = 'idRegistrar'; // Ссылка на регистратор записи
  static const String uidWarehouse = 'uidWarehouse';
  static const String uidProduct = 'uidProduct';
  static const String uidProductCharacteristic = 'uidProductCharacteristic';
  static const String uidUnit = 'uidUnit';
  static const String count = 'count';
}

/// Создание таблиц БД
Future createTableAccumProductRests(db) async {
  await db.execute('''
    CREATE TABLE $tableAccumProductRests (    
      ${ItemAccumProductRestsFields.id} $idType,
      ${ItemAccumProductRestsFields.idRegistrar} $integerType,
      ${ItemAccumProductRestsFields.uidWarehouse} $textType,      
      ${ItemAccumProductRestsFields.uidProduct} $textType,
      ${ItemAccumProductRestsFields.uidProductCharacteristic} $textType,
      ${ItemAccumProductRestsFields.uidUnit} $textType,      
      ${ItemAccumProductRestsFields.count} $realType                  
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<AccumProductRest> dbCreateProductRest(AccumProductRest accumProductRest) async {
  final db = await instance.database;
  final id =
  await db.insert(tableAccumProductRests, accumProductRest.toJson());
  accumProductRest.id = id;
  return accumProductRest;
}

Future<int> dbUpdateProductRest(AccumProductRest accumProductRest) async {
  final db = await instance.database;
  return db.update(
    tableAccumProductRests,
    accumProductRest.toJson(),
    where: '${ItemAccumProductRestsFields.id} = ?',
    whereArgs: [accumProductRest.id],
  );
}

Future<int> dbDeleteProductRest({
  required String uidWarehouse,
  required String uidProduct,
  required String uidProductCharacteristic}) async {

  final db = await instance.database;
  return await db.delete(
    tableAccumProductRests,
    where:
    '${ItemAccumProductRestsFields.uidWarehouse} = ? '
        'AND ${ItemAccumProductRestsFields.uidProduct} = ?'
        'AND ${ItemAccumProductRestsFields.uidProductCharacteristic} = ?',
    whereArgs: [uidWarehouse, uidProduct, uidProductCharacteristic],
  );
}

Future<int> dbDeleteAllProductRest() async {
  final db = await instance.database;
  return await db.delete(
    tableAccumProductRests,
  );
}

Future<double> dbReadProductRest({
  required String uidWarehouse,
  required String uidProduct,
  required String uidProductCharacteristic}) async {

  final db = await instance.database;
  final maps = await db.query(
    tableAccumProductRests,
    where:
    '${ItemAccumProductRestsFields.uidWarehouse} = ? '
        'AND ${ItemAccumProductRestsFields.uidProduct} = ?'
        'AND ${ItemAccumProductRestsFields.uidProductCharacteristic} = ?',
    whereArgs: [uidWarehouse, uidProduct, uidProductCharacteristic],
  );

  if (maps.isNotEmpty) {
    return AccumProductRest.fromJson(maps.first).count;
  } else {
    return 0.0;
  }
}

Future<List<AccumProductRest>> readAllProductRest() async {
  final db = await instance.database;
  final result = await db.query(tableAccumProductRests);
  return result.map((json) => AccumProductRest.fromJson(json)).toList();
}