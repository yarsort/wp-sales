import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/inforg_return_percents_.dart';

/// Название таблиц базы данных
const String tableInfoRgReturnPercents = '_InfoRgReturnPercents';

/// Поля для базы данных
class ItemInfoRgReturnPercentsFields {
  static final List<String> values = [
    id,
    uidPartner,
    uidProduct,
    percent,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String uidPartner = 'uidPartner';
  static const String uidProduct = 'uidProduct';
  static const String percent = 'percent';
}

/// Создание таблиц БД
Future createTableInfoRgReturnPercents(db) async {
  await db.execute('''
    CREATE TABLE $tableInfoRgReturnPercents (    
      ${ItemInfoRgReturnPercentsFields.id} $idType,            
      ${ItemInfoRgReturnPercentsFields.uidPartner} $textType,
      ${ItemInfoRgReturnPercentsFields.uidProduct} $textType,      
      ${ItemInfoRgReturnPercentsFields.percent} $realType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<InfoRgReturnPercents> dbCreateInfoRgReturnPercent(InfoRgReturnPercents infoRgReturnPercents) async {
  final db = await instance.database;
  final id = await db.insert(
      tableInfoRgReturnPercents,
      infoRgReturnPercents.toJson());
  infoRgReturnPercents.id = id;
  return infoRgReturnPercents;
}

Future<int> dbUpdateInfoRgReturnPercent(InfoRgReturnPercents infoRgReturnPercents) async {
  final db = await instance.database;
  return db.update(
    tableInfoRgReturnPercents,
    infoRgReturnPercents.toJson(),
    where: '${ItemInfoRgReturnPercentsFields.id} = ?',
    whereArgs: [infoRgReturnPercents.id],
  );
}

Future<int> dbDeleteInfoRgReturnPercent(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableInfoRgReturnPercents,
    where: '${ItemInfoRgReturnPercentsFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllInfoRgReturnPercents() async {
  final db = await instance.database;
  return await db.delete(
    tableInfoRgReturnPercents);
}

Future<InfoRgReturnPercents> dbReadInfoRgReturnPercent(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableInfoRgReturnPercents,
    columns: ItemInfoRgReturnPercentsFields.values,
    where: '${ItemInfoRgReturnPercentsFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return InfoRgReturnPercents.fromJson(maps.first);
  } else {
    return InfoRgReturnPercents();
  }
}

Future<InfoRgReturnPercents> dbReadInfoRgReturnPercents(String uidPartner, String uidProduct) async {
  final db = await instance.database;
  final maps = await db.query(
    tableInfoRgReturnPercents,
    columns: ItemInfoRgReturnPercentsFields.values,
    where: '${ItemInfoRgReturnPercentsFields.uidPartner} = ? AND ${ItemInfoRgReturnPercentsFields.uidProduct} = ?',
    whereArgs: [uidPartner, uidProduct],
  );

  if (maps.isNotEmpty) {
    return InfoRgReturnPercents.fromJson(maps.first);
  } else {
    return InfoRgReturnPercents();
  }
}

Future<List<InfoRgReturnPercents>> dbReadAllInfoRgReturnPercents() async {
  final db = await instance.database;
  final result = await db.query(tableInfoRgReturnPercents);
  return result.map((json) => InfoRgReturnPercents.fromJson(json)).toList();
}

Future<int> dbGetCountInfoRgReturnPercent() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableInfoRgReturnPercents"));
  return result ?? 0;
}
