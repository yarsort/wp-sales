import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/models/contract.dart';
import 'package:wp_sales/models/currency.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/organization.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/models/price.dart';

final DB instance = DB._init();

class DB {

  static Database? _database;

  DB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('WPSalesDatabase.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    /// Документ.ЗаказПокупателя
    await db.execute('''
    CREATE TABLE $tableOrderCustomer (    
      ${OrderCustomerFields.id} $idType, 
      ${OrderCustomerFields.status} $integerType,
      ${OrderCustomerFields.date} $textType,
      ${OrderCustomerFields.uid} $textType,
      ${OrderCustomerFields.uidOrganization} $textType,
      ${OrderCustomerFields.nameOrganization} $textType,
      ${OrderCustomerFields.uidPartner} $textType,
      ${OrderCustomerFields.namePartner} $textType,
      ${OrderCustomerFields.uidContract} $textType,
      ${OrderCustomerFields.nameContract} $textType,  
      ${OrderCustomerFields.uidPrice} $textType,
      ${OrderCustomerFields.namePrice} $textType,
      ${OrderCustomerFields.uidWarehouse} $textType,
      ${OrderCustomerFields.nameWarehouse} $textType,
      ${OrderCustomerFields.uidCurrency} $textType,
      ${OrderCustomerFields.nameCurrency} $textType,
      ${OrderCustomerFields.sum} $realType,
      ${OrderCustomerFields.comment} $textType,
      ${OrderCustomerFields.dateSending} $textType,
      ${OrderCustomerFields.datePaying} $textType,
      ${OrderCustomerFields.sendYesTo1C} $integerType,
      ${OrderCustomerFields.sendNoTo1C} $integerType,
      ${OrderCustomerFields.dateSendingTo1C} $textType,
      ${OrderCustomerFields.numberFrom1C} $textType,
      ${OrderCustomerFields.countItems} $integerType
      )
    ''');

    /// Документ.ЗаказПокупателя - ТЧ "Товары" (№1)
    await db.execute('''
    CREATE TABLE $tableOrderCustomer (    
      ${ItemOrderCustomerFields.id} $idType,
      ${ItemOrderCustomerFields.idOrderCustomer} $idType,      
      ${ItemOrderCustomerFields.uid} $textType,
      ${ItemOrderCustomerFields.name} $textType,      
      ${ItemOrderCustomerFields.uidUnit} $textType,
      ${ItemOrderCustomerFields.nameUnit} $textType,
      ${ItemOrderCustomerFields.count} $integerType,
      ${ItemOrderCustomerFields.price} $integerType,
      ${ItemOrderCustomerFields.discount} $integerType,
      ${ItemOrderCustomerFields.sum} $integerType      
      )
    ''');

    /// Справочник.Организации
    await db.execute('''
    CREATE TABLE $tableOrganization (    
      ${ItemOrganizationFields.id} $idType,
      ${ItemOrganizationFields.isGroup} $idType,      
      ${ItemOrganizationFields.uid} $textType,
      ${ItemOrganizationFields.code} $textType,      
      ${ItemOrganizationFields.name} $textType,
      ${ItemOrganizationFields.uidParent} $textType,
      ${ItemOrganizationFields.phone} $textType,
      ${ItemOrganizationFields.address} $textType,
      ${ItemOrganizationFields.comment} $textType            
      )
    ''');

    /// Справочник.Партнеры
    await db.execute('''
    CREATE TABLE $tablePartner (    
      ${ItemPartnerFields.id} $idType,
      ${ItemPartnerFields.isGroup} $idType,      
      ${ItemPartnerFields.uid} $textType,
      ${ItemPartnerFields.code} $textType,      
      ${ItemPartnerFields.name} $textType,
      ${ItemPartnerFields.uidParent} $textType,
      ${ItemPartnerFields.balance} $integerType,
      ${ItemPartnerFields.balanceForPayment} $integerType,      
      ${ItemPartnerFields.phone} $textType,
      ${ItemPartnerFields.address} $textType,
      ${ItemPartnerFields.comment} $textType,
      ${ItemPartnerFields.schedulePayment} $integerType            
      )
    ''');

    /// Справочник.ДоговорыПартнеров (Контракты)
    await db.execute('''
    CREATE TABLE $tableContract (
      ${ItemContractFields.id} $idType,
      ${ItemContractFields.isGroup} $idType,
      ${ItemContractFields.uid} $textType,
      ${ItemContractFields.code} $textType,
      ${ItemContractFields.name} $textType,
      ${ItemContractFields.uidParent} $textType,
      ${ItemContractFields.balance} $integerType,
      ${ItemContractFields.balanceForPayment} $integerType,
      ${ItemContractFields.phone} $textType,
      ${ItemContractFields.address} $textType,
      ${ItemContractFields.comment} $textType,
      ${ItemContractFields.namePartner} $textType,
      ${ItemContractFields.uidPartner} $textType,
      ${ItemContractFields.uidPrice} $textType,
      ${ItemContractFields.namePrice} $textType,
      ${ItemContractFields.uidCurrency} $textType,
      ${ItemContractFields.nameCurrency} $textType,
      ${ItemContractFields.schedulePayment} $integerType
      )
    ''');

    /// Справочник.ТипЦенНоменклатуры
    await db.execute('''
    CREATE TABLE $tablePrice (    
      ${ItemPriceFields.id} $idType,
      ${ItemPriceFields.isGroup} $idType,      
      ${ItemPriceFields.uid} $textType,
      ${ItemPriceFields.code} $textType,      
      ${ItemPriceFields.name} $textType,
      ${ItemPriceFields.uidParent} $textType,
      ${ItemPriceFields.comment} $textType            
      )
    ''');

    /// Справочник.Валюты
    await db.execute('''
    CREATE TABLE $tableCurrency (    
      ${ItemCurrencyFields.id} $idType,
      ${ItemCurrencyFields.isGroup} $idType,      
      ${ItemCurrencyFields.uid} $textType,
      ${ItemCurrencyFields.code} $textType,      
      ${ItemCurrencyFields.name} $textType,
      ${ItemCurrencyFields.uidParent} $textType,
      ${ItemCurrencyFields.comment} $textType            
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class DBOrderCustomer {

  Future<OrderCustomer> createOrderCustomer(OrderCustomer orderCustomer) async {
    final db = await instance.database;
    final id = await db.insert(tableOrderCustomer, orderCustomer.toJson());
    orderCustomer.id = id;
    return orderCustomer;
  }

  Future<OrderCustomer> readOrderCustomer(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableOrderCustomer,
      columns: OrderCustomerFields.values,
      where: '${OrderCustomerFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return OrderCustomer.fromJson(maps.first);
    } else {
      throw Exception('Запись с ID: $id не обнаружена!');
    }
  }

  Future<List<OrderCustomer>> readAllOrderCustomer() async {
    final db = await instance.database;

    const orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(tableOrderCustomer, orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<int> updateOrderCustomer(OrderCustomer orderCustomer) async {
    final db = await instance.database;
    return db.update(
      tableOrderCustomer,
      orderCustomer.toJson(),
      where: '${OrderCustomerFields.id} = ?',
      whereArgs: [orderCustomer.id],
    );
  }

  Future<int> deleteOrderCustomer(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableOrderCustomer,
      where: '${OrderCustomerFields.id} = ?',
      whereArgs: [id],
    );
  }

}