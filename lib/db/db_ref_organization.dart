import 'package:sqflite/sqflite.dart';
import 'init_db.dart';
import 'package:wp_sales/models/ref_organization.dart';

const String tableOrganization   = '_ReferenceOrganization';

/// Поля для базы данных
class ItemOrganizationFields {
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

}

/// Справочник.Организации
Future<Organization> dbCreateOrganization(Organization organization) async {
  final db = await instance.database;
  final id = await db.insert(tableOrganization, organization.toJson());
  organization.id = id;
  return organization;
}

Future<int> dbUpdateOrganization(Organization organization) async {
  final db = await instance.database;
  return db.update(
    tableOrganization,
    organization.toJson(),
    where: '${ItemOrganizationFields.id} = ?',
    whereArgs: [organization.id],
  );
}

Future<int> dbDeleteOrganization(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableOrganization,
    where: '${ItemOrganizationFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllOrganization() async {
  final db = await instance.database;
  return await db.delete(
    tableOrganization,
  );
}

Future<Organization> dbReadOrganization(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tableOrganization,
    columns: ItemOrganizationFields.values,
    where: '${ItemOrganizationFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Organization.fromJson(maps.first);
  } else {
    return Organization();
  }
}

Future<Organization> dbReadOrganizationUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tableOrganization,
    columns: ItemOrganizationFields.values,
    where: '${ItemOrganizationFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Organization.fromJson(maps.first);
  } else {
    return Organization();
  }
}

Future<List<Organization>> dbReadAllOrganization() async {
  final db = await instance.database;

  const orderBy = '${ItemOrganizationFields.name} ASC';
  final result = await db.query(tableOrganization, orderBy: orderBy);

  return result.map((json) => Organization.fromJson(json)).toList();
}

Future<int> dbGetCountOrganization() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tableOrganization"));
  return result ?? 0;
}