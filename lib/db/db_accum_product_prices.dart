import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/accum_product_prices.dart';

/// Название таблиц базы данных
const String tableAccumProductPrices   = '_AccumProductPrices';

/// Поля для базы данных
class ItemAccumProductPricesFields {
  static final List<String> values = [
    id,
    uidPrice,
    uidProduct,
    uidProductCharacteristic,
    uidUnit,
    price,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uidPrice = 'uidPrice';
  static const String uidProduct = 'uidProduct';
  static const String uidProductCharacteristic = 'uidProductCharacteristic';
  static const String uidUnit = 'uidUnit';
  static const String price = 'price';
}

/// Создание таблиц БД
Future createTableAccumProductPrices(db) async {
  await db.execute('''
    CREATE TABLE $tableAccumProductPrices (    
      ${ItemAccumProductPricesFields.id} $idType,
      ${ItemAccumProductPricesFields.uidPrice} $textType,      
      ${ItemAccumProductPricesFields.uidProduct} $textType,
      ${ItemAccumProductPricesFields.uidProductCharacteristic} $textType,
      ${ItemAccumProductPricesFields.uidUnit} $textType,      
      ${ItemAccumProductPricesFields.price} $realType                  
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<AccumProductPrice> dbCreateProductPrice(AccumProductPrice accumProductPrice) async {

  final db = await instance.database;
  final id =
  await db.insert(
      tableAccumProductPrices,
      accumProductPrice.toJson());
  accumProductPrice.id = id;
  return accumProductPrice;
}

Future<int> dbUpdateProductPrice(AccumProductPrice accumProductPrice) async {
  final db = await instance.database;
  return db.update(
    tableAccumProductPrices,
    accumProductPrice.toJson(),
    where: '${ItemAccumProductPricesFields.id} = ?',
    whereArgs: [accumProductPrice.id],
  );
}

Future<int> dbDeleteProductPrice(
    {required String uidPrice,
      required String uidProduct,
      required String uidProductCharacteristic}) async {

  final db = await instance.database;
  return await db.delete(
    tableAccumProductPrices,
    where:
    '${ItemAccumProductPricesFields.uidPrice} = ? '
        'AND ${ItemAccumProductPricesFields.uidProduct} = ?'
        'AND ${ItemAccumProductPricesFields.uidProductCharacteristic} = ?',
    whereArgs: [uidPrice, uidProduct, uidProductCharacteristic],
  );
}

Future<int> dbDeleteAllProductPrice() async {
  final db = await instance.database;
  return await db.delete(
    tableAccumProductPrices,
  );
}

Future<double> dbReadProductPrice(
    {required String uidPrice,
      required String uidProduct,
      required String uidProductCharacteristic}) async {

  final db = await instance.database;
  final maps = await db.query(
    tableAccumProductPrices,
    columns: ItemAccumProductPricesFields.values,
    where:
    '${ItemAccumProductPricesFields.uidPrice} = ? '
        'AND ${ItemAccumProductPricesFields.uidProduct} = ?'
        'AND ${ItemAccumProductPricesFields.uidProductCharacteristic} = ?',
    whereArgs: [uidPrice, uidProduct, uidProductCharacteristic],
  );

  if (maps.isNotEmpty) {
    return AccumProductPrice.fromJson(maps.first).price;
  } else {
    return 0.0;
  }
}

Future<List<AccumProductPrice>> dbReadAllAccumProductPrice() async {
  final db = await instance.database;
  const orderBy = '${ItemAccumProductPricesFields.price} ASC';
  final result = await db.query(
      tableAccumProductPrices,
      orderBy: orderBy);
  return result.map((json) => AccumProductPrice.fromJson(json)).toList();
}

Future<List<AccumProductPrice>> dbReadAccumProductPriceByUIDProducts(listProductsUID) async {
  final db = await instance.database;
  final result = await db.query(
      tableAccumProductPrices,
      where:
      'uidProduct IN (${listProductsUID.map((e) => "'$e'").join(', ')})');
  return result.map((json) => AccumProductPrice.fromJson(json)).toList();
}