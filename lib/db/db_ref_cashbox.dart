import 'package:sqflite/sqflite.dart';
import 'init_db.dart';
import 'package:wp_sales/models/ref_cashbox.dart';

///***********************************
/// Название таблиц базы данных
///***********************************
const String tableCashbox   = '_ReferenceCashbox';

/// Поля для базы данных
class ItemCashboxFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    uidParent,
    comment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String uidParent = 'uidParent';
  static const String comment = 'comment';

}

/// Справочник.Кассы
Future<Cashbox> dbCreateCashbox(Cashbox cashbox) async {
  final db = await instance.database;
  final id = await db.insert(tableCashbox, cashbox.toJson());
  cashbox.id = id;
  return cashbox;
}

Future<int> dbUpdateCashbox(Cashbox cashbox) async {
  final db = await instance.database;
  return db.update(
    tableCashbox,
    cashbox.toJson(),
    where: '${ItemCashboxFields.id} = ?',
    whereArgs: [cashbox.id],
  );
}

Future<int> dbDeleteCashbox(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableCashbox,
    where: '${ItemCashboxFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllCashbox() async {
  final db = await instance.database;
  return await db.delete(
    tableCashbox,
  );
}

Future<Cashbox> dbReadCashbox(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableCashbox,
    columns: ItemCashboxFields.values,
    where: '${ItemCashboxFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Cashbox.fromJson(maps.first);
  } else {
    throw Cashbox();
  }
}

Future<List<Cashbox>> dbReadAllCashbox() async {
  final db = await instance.database;
  const orderBy = '${ItemCashboxFields.name} ASC';
  final result = await db.query(tableCashbox, orderBy: orderBy);
  return result.map((json) => Cashbox.fromJson(json)).toList();
}

Future<int> dbGetCountCashbox() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableCashbox"));
  return result ?? 0;
}