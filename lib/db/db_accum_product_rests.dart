
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/accum_product_rests.dart';

/// Название таблиц базы данных
const String tableAccumProductRests   = '_AccumProductRests';

/// Поля для базы данных
class ItemAccumProductRestsFields {
  static final List<String> values = [
    id,
    uidWarehouse,
    uidProduct,
    uidUnit,
    count,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uidWarehouse = 'uidWarehouse';
  static const String uidProduct = 'uidProduct';
  static const String uidUnit = 'uidUnit';
  static const String count = 'count';
}

/// РегистрНакопления.ОстаткиНаСкладах
Future<AccumProductRest> dbCreateProductRest(
    AccumProductRest accumProductRest) async {
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

Future<int> dbDeleteProductRest(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableAccumProductRests,
    where: '${ItemAccumProductRestsFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllProductRest() async {
  final db = await instance.database;
  return await db.delete(
    tableAccumProductRests,
  );
}

Future<double> dbReadProductRest(
    {required String uidWarehouse, required String uidProduct}) async {
  final db = await instance.database;
  final maps = await db.query(
    tableAccumProductRests,
    columns: ItemAccumProductRestsFields.values,
    where:
    '${ItemAccumProductRestsFields.uidWarehouse} = ? AND ${ItemAccumProductRestsFields.uidProduct} = ?',
    whereArgs: [uidWarehouse, uidProduct],
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