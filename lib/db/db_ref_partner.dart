
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/ref_partner.dart';


/// Название таблиц базы данных
const String tablePartner   = '_ReferencePartner';

/// Поля для базы данных
class ItemPartnerFields {
  static final List<String> values = [
    id,
    isGroup,
    uid,
    code,
    name,
    nameForSearch,
    uidParent,
    balance,
    balanceForPayment,
    phone,
    address,
    comment,
    dateEdit,
    schedulePayment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id';// Инкремент
  static const String isGroup = 'isGroup'; // Каталог в иерархии
  static const String uid = 'uid';
  static const String code = 'code';
  static const String name = 'name';
  static const String nameForSearch = 'nameForSearch';
  static const String uidParent = 'uidParent';
  static const String balance = 'balance';
  static const String balanceForPayment = 'balanceForPayment';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String comment = 'comment';
  static const String dateEdit = 'dateEdit';
  static const String schedulePayment = 'schedulePayment';
}

Future createTablePartner(db) async {

  // Удалим если она существовала до этого
  await db.execute("DROP TABLE IF EXISTS $tablePartner");

  await db.execute('''
    CREATE TABLE $tablePartner (    
      ${ItemPartnerFields.id} $idType,
      ${ItemPartnerFields.isGroup} $integerType,      
      ${ItemPartnerFields.uid} $textType,
      ${ItemPartnerFields.code} $textType,      
      ${ItemPartnerFields.name} $textType,
      ${ItemPartnerFields.nameForSearch} $textType,
      ${ItemPartnerFields.uidParent} $textType,
      ${ItemPartnerFields.balance} $realType,
      ${ItemPartnerFields.balanceForPayment} $realType,      
      ${ItemPartnerFields.phone} $textType,
      ${ItemPartnerFields.address} $textType,
      ${ItemPartnerFields.comment} $textType,
      ${ItemPartnerFields.dateEdit} $textType,
      ${ItemPartnerFields.schedulePayment} $integerType            
      )
    ''');
}

/// Справочник.Партнеры
Future<Partner> dbCreatePartner(Partner partner) async {
  final db = await instance.database;
  final id = await db.insert(tablePartner, partner.toJson());
  partner.id = id;
  return partner;
}

Future<int> dbUpdatePartner(Partner partner) async {
  final db = await instance.database;
  return db.update(
    tablePartner,
    partner.toJson(),
    where: '${ItemPartnerFields.id} = ?',
    whereArgs: [partner.id],
  );
}

Future<int> dbDeletePartner(int id) async {
  final db = await instance.database;
  return await db.delete(
    tablePartner,
    where: '${ItemPartnerFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllPartner() async {
  final db = await instance.database;
  return await db.delete(
    tablePartner,
  );
}

Future<Partner> dbReadPartner(int id) async {
  final db = await instance.database;
  final maps = await db.query(
    tablePartner,
    columns: ItemPartnerFields.values,
    where: '${ItemPartnerFields.id} = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return Partner.fromJson(maps.first);
  } else {
    return Partner();
  }
}

Future<Partner> dbReadPartnerUID(String uid) async {
  final db = await instance.database;
  final maps = await db.query(
    tablePartner,
    columns: ItemPartnerFields.values,
    where: '${ItemPartnerFields.uid} = ?',
    whereArgs: [uid],
  );

  if (maps.isNotEmpty) {
    return Partner.fromJson(maps.first);
  } else {
    return Partner();
  }
}

Future<List<Partner>> dbReadAllPartners() async {
  final db = await instance.database;

  const orderBy = '${ItemPartnerFields.name} ASC';
  final result = await db.query(tablePartner, orderBy: orderBy);

  return result.map((json) => Partner.fromJson(json)).toList();
}

Future<List<Partner>> dbReadPartnersForSearch(searchString) async {
  final db = await instance.database;
  const orderBy = '${ItemPartnerFields.name} ASC';
  final result = await db.query(tablePartner,
      where: '${ItemPartnerFields.nameForSearch} LIKE ?',
      whereArgs: ['%$searchString%'],
      orderBy: orderBy);
  return result.map((json) => Partner.fromJson(json)).toList();
}

Future<List<Partner>> dbReadPartnersByParent(String uidParent) async {
  final db = await instance.database;
  const orderBy = '${ItemPartnerFields.name} ASC';
  final result = await db.query(tablePartner,
      where: '${ItemPartnerFields.uidParent} = ?',
      whereArgs: [uidParent],
      orderBy: orderBy);
  return result.map((json) => Partner.fromJson(json)).toList();
}

Future<int> dbGetCountPartner() async {
  final db = await instance.database;
  var result = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT (*) FROM $tablePartner"));
  return result ?? 0;
}