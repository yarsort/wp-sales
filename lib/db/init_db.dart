import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/models/contract.dart';
import 'package:wp_sales/models/currency.dart';
import 'package:wp_sales/models/order_customer.dart';
import 'package:wp_sales/models/organization.dart';
import 'package:wp_sales/models/partner.dart';
import 'package:wp_sales/models/price.dart';

final DatabaseHelper instance = DatabaseHelper._init();

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('WPSalesDatabase_temp1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB);
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
    CREATE TABLE $tableItemsOrderCustomer (    
      ${ItemOrderCustomerFields.id} $idType,
      ${ItemOrderCustomerFields.idOrderCustomer} $integerType,      
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
      ${ItemOrganizationFields.isGroup} $integerType,      
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
      ${ItemPartnerFields.isGroup} $integerType,      
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
      ${ItemContractFields.isGroup} $integerType,
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
      ${ItemPriceFields.isGroup} $integerType,      
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
      ${ItemCurrencyFields.isGroup} $integerType,      
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


  /// ***********************************
  /// Справочник.Организации
  /// ***********************************
  Future<Organization> createOrganization(Organization organization) async {
    final db = await instance.database;
    final id = await db.insert(tableOrganization, organization.toJson());
    organization.id = id;
    return organization;
  }

  Future<int> updateOrganization(Organization organization) async {
    final db = await instance.database;
    return db.update(
      tableOrganization,
      organization.toJson(),
      where: '${ItemOrganizationFields.id} = ?',
      whereArgs: [organization.id],
    );
  }

  Future<int> deleteOrganization(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableOrganization,
      where: '${ItemOrganizationFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Organization> readOrganization(int id) async {
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
      throw Exception('Запись с ID: $id не обнаружена!');
    }
  }

  Future<List<Organization>> readAllOrganization() async {
    final db = await instance.database;

    const orderBy = '${ItemOrganizationFields.name} ASC';
    final result = await db.query(
        tableOrganization,
        orderBy: orderBy);

    return result.map((json) => Organization.fromJson(json)).toList();
  }

  Future<int> getCountOrganization() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT (*) FROM $tableOrganization"));
    return result ?? 0;
  }


  /// ***********************************
  /// Справочник.Партнеры
  /// ***********************************
  Future<Partner> createPartner(Partner partner) async {
    final db = await instance.database;
    final id = await db.insert(tablePartner, partner.toJson());
    partner.id = id;
    return partner;
  }

  Future<int> updatePartner(Partner partner) async {
    final db = await instance.database;
    return db.update(
      tablePartner,
      partner.toJson(),
      where: '${ItemPartnerFields.id} = ?',
      whereArgs: [partner.id],
    );
  }

  Future<int> deletePartner(int id) async {
    final db = await instance.database;
    return await db.delete(
      tablePartner,
      where: '${ItemPartnerFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Partner> readPartner(int id) async {
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
      throw Exception('Запись с ID: $id не обнаружена!');
    }
  }

  Future<List<Partner>> readAllPartners() async {
    final db = await instance.database;

    const orderBy = '${ItemPartnerFields.name} ASC';
    final result = await db.query(
        tablePartner,
        orderBy: orderBy);

    return result.map((json) => Partner.fromJson(json)).toList();
  }

  Future<int> getCountPartner() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT (*) FROM $tablePartner"));
    return result ?? 0;
  }


  /// ***********************************
  /// Справочник.ДоговорыКонтрагентов (партнеров)
  /// ***********************************
  Future<Contract> createContract(Contract contract) async {
    final db = await instance.database;
    final id = await db.insert(tableContract, contract.toJson());
    contract.id = id;
    return contract;
  }

  Future<int> updateContract(Contract contract) async {
    final db = await instance.database;
    return db.update(
      tableContract,
      contract.toJson(),
      where: '${ItemContractFields.id} = ?',
      whereArgs: [contract.id],
    );
  }

  Future<int> deleteContract(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableContract,
      where: '${ItemContractFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Contract> readContract(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableContract,
      columns: ItemContractFields.values,
      where: '${ItemContractFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contract.fromJson(maps.first);
    } else {
      throw Exception('Запись с ID: $id не обнаружена!');
    }
  }

  Future<List<Contract>> readAllContracts() async {
    final db = await instance.database;
    const orderBy = '${ItemContractFields.name} ASC';
    final result = await db.query(
        tableContract,
        orderBy: orderBy);
    return result.map((json) => Contract.fromJson(json)).toList();
  }

  Future<int> getCountContract() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT (*) FROM $tableContract"));
    return result ?? 0;
  }


  /// ***********************************
  /// Справочник.ТипыЦен
  /// ***********************************
  Future<Price> createPrice(Price price) async {
    final db = await instance.database;
    final id = await db.insert(tablePrice, price.toJson());
    price.id = id;
    return price;
  }

  Future<int> updatePrice(Price price) async {
    final db = await instance.database;
    return db.update(
      tablePrice,
      price.toJson(),
      where: '${ItemPriceFields.id} = ?',
      whereArgs: [price.id],
    );
  }

  Future<int> deletePrice(int id) async {
    final db = await instance.database;
    return await db.delete(
      tablePrice,
      where: '${ItemPriceFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Price> readPrice(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tablePrice,
      columns: ItemPriceFields.values,
      where: '${ItemPriceFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Price.fromJson(maps.first);
    } else {
      throw Exception('Запись с ID: $id не обнаружена!');
    }
  }

  Future<List<Price>> readAllPrices() async {
    final db = await instance.database;
    const orderBy = '${ItemPriceFields.name} ASC';
    final result = await db.query(
        tablePrice,
        orderBy: orderBy);
    return result.map((json) => Price.fromJson(json)).toList();
  }

  Future<int> getCountPrice() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT (*) FROM $tablePrice"));
    return result ?? 0;
  }


  /// ***********************************
  /// Справочник.Валюты
  /// ***********************************
  Future<Currency> createCurrency(Currency currency) async {
    final db = await instance.database;
    final id = await db.insert(tableCurrency, currency.toJson());
    currency.id = id;
    return currency;
  }

  Future<int> updateCurrency(Currency price) async {
    final db = await instance.database;
    return db.update(
      tableCurrency,
      price.toJson(),
      where: '${ItemCurrencyFields.id} = ?',
      whereArgs: [price.id],
    );
  }

  Future<int> deleteCurrency(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableCurrency,
      where: '${ItemCurrencyFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Currency> readCurrency(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableCurrency,
      columns: ItemCurrencyFields.values,
      where: '${ItemCurrencyFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Currency.fromJson(maps.first);
    } else {
      throw Exception('Запись с ID: $id не обнаружена!');
    }
  }

  Future<List<Currency>> readAllCurrency() async {
    final db = await instance.database;
    const orderBy = '${ItemCurrencyFields.name} ASC';
    final result = await db.query(
        tableCurrency,
        orderBy: orderBy);
    return result.map((json) => Currency.fromJson(json)).toList();
  }

  Future<int> getCountCurrency() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT (*) FROM $tableCurrency"));
    return result ?? 0;
  }


  /// ***********************************
  /// Документы.ЗаказПокупателя
  /// ***********************************
  Future<OrderCustomer> createOrderCustomer(OrderCustomer orderCustomer) async {
    final db = await instance.database;
    final id = await db.insert(tableOrderCustomer, orderCustomer.toJson());
    orderCustomer.id = id;
    return orderCustomer;
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

  Future<List<OrderCustomer>> readAllNewOrderCustomer() async {
    final db = await instance.database;
    const orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(
        tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [0],
        orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<List<OrderCustomer>> readAllSendOrderCustomer() async {
    final db = await instance.database;
    const orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(
        tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [1],
        orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<List<OrderCustomer>> readAllTrashOrderCustomer() async {
    final db = await instance.database;
    const orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(
        tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [2],
        orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<int> getCountOrderCustomer() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT (*) FROM $tableOrderCustomer"));
    return result ?? 0;
  }

  Future<int> getCountNewOrderCustomer() async {
    final db = await instance.database;
    final result = await db.query(
        tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [0]);
    return result.map((json) => OrderCustomer.fromJson(json)).toList().length;
  }

  Future<int> getCountSendOrderCustomer() async {
    final db = await instance.database;
    final result = await db.query(
        tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [1]);
    return result.map((json) => OrderCustomer.fromJson(json)).toList().length;
  }

  Future<int> getCountTrashOrderCustomer() async {
    final db = await instance.database;
    final result = await db.query(
        tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [2]);
    return result.map((json) => OrderCustomer.fromJson(json)).toList().length;
  }

}