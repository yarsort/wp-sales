
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_unit.dart';

/// Название таблиц базы данных
const String tableUnit   = '_ReferenceUnit';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

/// Поля для базы данных
class ItemUnitFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    multiplicity,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String multiplicity = 'multiplicity';
  static const String comment = 'comment';
}

/// Создание таблиц БД
Future createTableUnit(db) async {
  await db.execute('''
    CREATE TABLE $tableUnit(    
      ${ItemUnitFields.id} $idType,
      ${ItemUnitFields.isGroup} $integerType,      
      ${ItemUnitFields.uid} $textType,
      ${ItemUnitFields.code} $textType,      
      ${ItemUnitFields.name} $textType,
      ${ItemUnitFields.uidParent} $textType,      
      ${ItemUnitFields.multiplicity} $realType,
      ${ItemUnitFields.comment} $textType            
      )
    ''');
}

/// Операции с объектами: CRUD and more
Future<Unit> dbCreateUnit(Unit unit) async {
  final db = await instance.database;
  final id = await db.insert(tableUnit, unit.toJson());
  unit.id = id;
  return unit;
}

Future<int> dbUpdateUnit(Unit unit) async {
  final db = await instance.database;
  return db.update(
    tableUnit,
    unit.toJson(),
    where: '${ItemUnitFields.id} = ?',
    whereArgs: [unit.id],
  );
}

Future<int> dbDeleteUnit(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableUnit,
    where: '${ItemUnitFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllUnit() async {
  final db = await instance.database;
  return await db.delete(
    tableUnit,
  );
}

Future<Unit> dbReadUnit(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableUnit,
    columns: ItemUnitFields.values,
    where: '${ItemUnitFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Unit.fromJson(maps.first);
  } else {
    return Unit();
  }
}

Future<Unit> dbReadUnitUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableUnit,
    columns: ItemUnitFields.values,
    where: '${ItemUnitFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Unit.fromJson(maps.first);
  } else {
    return Unit();
  }
}

Future<List<Unit>> dbReadAllUnit() async {
  final db = await instance.database;
  const orderBy = '${ItemUnitFields.name} ASC';
  final result = await db.query(tableUnit, orderBy: orderBy);
  return result.map((json) => Unit.fromJson(json)).toList();
}

Future<int> dbGetCountUnit() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableUnit"));
  return result ?? 0;
}