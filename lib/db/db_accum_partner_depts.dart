
import 'package:wp_sales/db/init_db.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';

/// Название таблиц базы данных
const String tableAccumPartnerDebts   = '_AccumPartnerDebts';

/// Поля для базы данных
class ItemAccumPartnerDeptFields {
  static final List<String> values = [
    id,
    uidOrganization,
    uidPartner,
    uidContract,
    uidDoc,
    nameDoc,
    numberDoc,
    dateDoc,
    balance,
    balanceForPayment,
  ];

  /// Описание названий реквизитов таблицы ДБ в виде строк
  static const String id = 'id'; // Инкремент
  static const String uidOrganization = 'uidOrganization';
  static const String uidPartner = 'uidPartner';
  static const String uidContract = 'uidContract';
  static const String uidDoc = 'uidDoc';
  static const String nameDoc = 'nameDoc';
  static const String numberDoc = 'numberDoc';
  static const String dateDoc = 'dateDoc';
  static const String balance = 'balance';
  static const String balanceForPayment = 'balanceForPayment';
}

/// РегистрНакопления.Взаиморасчеты
Future<AccumPartnerDept> dbCreatePartnerDept(
    AccumPartnerDept accumDeptPartner) async {
  final db = await instance.database;
  final id =
  await db.insert(tableAccumPartnerDebts, accumDeptPartner.toJson());
  accumDeptPartner.id = id;
  return accumDeptPartner;
}

Future<int> dbUpdatePartnerDept(AccumPartnerDept accumDeptPartner) async {
  final db = await instance.database;
  return db.update(
    tableAccumPartnerDebts,
    accumDeptPartner.toJson(),
    where: '${ItemAccumPartnerDeptFields.id} = ?',
    whereArgs: [accumDeptPartner.id],
  );
}

Future<int> dbDeletePartnerDept(int id) async {
  final db = await instance.database;
  return await db.delete(
    tableAccumPartnerDebts,
    where: '${ItemAccumPartnerDeptFields.id} = ?',
    whereArgs: [id],
  );
}

Future<int> dbDeleteAllPartnerDept() async {
  final db = await instance.database;
  return await db.delete(
    tableAccumPartnerDebts,
  );
}

Future<AccumPartnerDept> dbReadPartnerDept(
    {required String uidPartner, required String uidContract}) async {
  final db = await instance.database;
  final maps = await db.query(
    tableAccumPartnerDebts,
    columns: ItemAccumPartnerDeptFields.values,
    where:
    '${ItemAccumPartnerDeptFields.uidPartner} = ? AND ${ItemAccumPartnerDeptFields.uidContract} = ?',
    whereArgs: [uidPartner, uidContract],
  );

  if (maps.isNotEmpty) {
    return AccumPartnerDept.fromJson(maps.first);
  } else {
    return AccumPartnerDept(); // Пустое значение
  }
}