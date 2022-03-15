import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/models/accum_partner_depts.dart';
import 'package:wp_sales/models/accum_product_prices.dart';
import 'package:wp_sales/models/accum_product_rests.dart';
import 'package:wp_sales/models/doc_order_customer.dart';
import 'package:wp_sales/models/ref_cashbox.dart';
import 'package:wp_sales/models/ref_contract.dart';
import 'package:wp_sales/models/ref_currency.dart';
import 'package:wp_sales/models/ref_organization.dart';
import 'package:wp_sales/models/ref_partner.dart';
import 'package:wp_sales/models/ref_price.dart';
import 'package:wp_sales/models/ref_product.dart';
import 'package:wp_sales/models/ref_unit.dart';
import 'package:wp_sales/models/ref_warehouse.dart';

final DatabaseHelper instance = DatabaseHelper._init();

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      if (_database!.isOpen) {
        return _database!;
      } else {
        _database = await _initDB('WPSalesDB.db');
        return _database!;
      }
    }
    _database = await _initDB('WPSalesDB.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 1, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _upgradeDB(Database db, int oldV, int newV) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    if (newV == 2) {

    }
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
      ${OrderCustomerFields.uidCashbox} $textType,
      ${OrderCustomerFields.nameCashbox} $textType,
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
      ${ItemOrderCustomerFields.count} $realType,
      ${ItemOrderCustomerFields.price} $realType,
      ${ItemOrderCustomerFields.discount} $realType,
      ${ItemOrderCustomerFields.sum} $realType      
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
      ${ItemPartnerFields.balance} $realType,
      ${ItemPartnerFields.balanceForPayment} $realType,      
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
      ${ItemContractFields.balance} $realType,
      ${ItemContractFields.balanceForPayment} $realType,
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
      ${ItemCurrencyFields.course} $realType,
      ${ItemCurrencyFields.multiplicity} $realType,
      ${ItemCurrencyFields.comment} $textType            
      )
    ''');

    /// Справочник.Кассы
    await db.execute('''
    CREATE TABLE $tableCashbox (    
      ${ItemCashboxFields.id} $idType,
      ${ItemCashboxFields.isGroup} $integerType,      
      ${ItemCashboxFields.uid} $textType,
      ${ItemCashboxFields.code} $textType,      
      ${ItemCashboxFields.name} $textType,
      ${ItemCashboxFields.uidParent} $textType,
      ${ItemCashboxFields.comment} $textType            
      )
    ''');

    /// Справочник.ЕдиницыИзмерения
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

    /// Справочник.Склады
    await db.execute('''
    CREATE TABLE $tableWarehouse (    
      ${ItemWarehouseFields.id} $idType,
      ${ItemWarehouseFields.isGroup} $integerType,      
      ${ItemWarehouseFields.uid} $textType,
      ${ItemWarehouseFields.code} $textType,      
      ${ItemWarehouseFields.name} $textType,
      ${ItemWarehouseFields.uidParent} $textType,
      ${ItemWarehouseFields.phone} $textType,
      ${ItemWarehouseFields.address} $textType,      
      ${ItemWarehouseFields.comment} $textType            
      )
    ''');

    /// Справочник.Товары
    await db.execute('''
    CREATE TABLE $tableProduct (    
      ${ItemProductFields.id} $idType,
      ${ItemProductFields.isGroup} $integerType,      
      ${ItemProductFields.uid} $textType,
      ${ItemProductFields.code} $textType,      
      ${ItemProductFields.name} $textType,
      ${ItemProductFields.vendorCode} $textType,
      ${ItemProductFields.uidParent} $textType,
      ${ItemProductFields.uidUnit} $textType,
      ${ItemProductFields.nameUnit} $textType,
      ${ItemProductFields.barcode} $textType,      
      ${ItemProductFields.comment} $textType            
      )
    ''');

    /// РегистрНакопления.Взаиморасчеты
    await db.execute('''
    CREATE TABLE $tableAccumPartnerDebts (    
      ${ItemAccumPartnerDeptFields.id} $idType,
      ${ItemAccumPartnerDeptFields.uidOrganization} $textType,      
      ${ItemAccumPartnerDeptFields.uidPartner} $textType,
      ${ItemAccumPartnerDeptFields.uidContract} $textType,      
      ${ItemAccumPartnerDeptFields.uidDoc} $textType,
      ${ItemAccumPartnerDeptFields.nameDoc} $textType,
      ${ItemAccumPartnerDeptFields.numberDoc} $textType,
      ${ItemAccumPartnerDeptFields.dateDoc} $textType,      
      ${ItemAccumPartnerDeptFields.balance} $realType,
      ${ItemAccumPartnerDeptFields.balanceForPayment} $realType            
      )
    ''');

    /// РегистрНакопления.Цены
    await db.execute('''
    CREATE TABLE $tableAccumProductPrices (    
      ${ItemAccumProductPricesFields.id} $idType,
      ${ItemAccumProductPricesFields.uidPrice} $textType,      
      ${ItemAccumProductPricesFields.uidProduct} $textType,
      ${ItemAccumProductPricesFields.uidUnit} $textType,      
      ${ItemAccumProductPricesFields.price} $realType                  
      )
    ''');

    /// РегистрНакопления.ОстаткиНаСкладах
    await db.execute('''
    CREATE TABLE $tableAccumProductRests (    
      ${ItemAccumProductRestsFields.id} $idType,
      ${ItemAccumProductRestsFields.uidWarehouse} $textType,      
      ${ItemAccumProductRestsFields.uidProduct} $textType,
      ${ItemAccumProductRestsFields.uidUnit} $textType,      
      ${ItemAccumProductRestsFields.count} $realType                  
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }

  /// Справочник.Организации
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

  Future<int> deleteAllOrganization() async {
    final db = await instance.database;
    return await db.delete(
      tableOrganization,
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
      throw Organization();
    }
  }

  Future<List<Organization>> readAllOrganization() async {
    final db = await instance.database;

    const orderBy = '${ItemOrganizationFields.name} ASC';
    final result = await db.query(tableOrganization, orderBy: orderBy);

    return result.map((json) => Organization.fromJson(json)).toList();
  }

  Future<int> getCountOrganization() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableOrganization"));
    return result ?? 0;
  }

  /// Справочник.Партнеры
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

  Future<int> deleteAllPartner() async {
    final db = await instance.database;
    return await db.delete(
      tablePartner,
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
      throw Partner();
    }
  }

  Future<List<Partner>> readAllPartners() async {
    final db = await instance.database;

    const orderBy = '${ItemPartnerFields.name} ASC';
    final result = await db.query(tablePartner, orderBy: orderBy);

    return result.map((json) => Partner.fromJson(json)).toList();
  }

  Future<int> getCountPartner() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tablePartner"));
    return result ?? 0;
  }

  /// Справочник.ДоговорыКонтрагентов (партнеров)
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

  Future<int> deleteAllContract() async {
    final db = await instance.database;
    return await db.delete(
      tableContract,
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
      throw Contract();
    }
  }

  Future<List<Contract>> readAllContracts() async {
    final db = await instance.database;
    const orderBy = '${ItemContractFields.name} ASC';
    final result = await db.query(tableContract, orderBy: orderBy);
    return result.map((json) => Contract.fromJson(json)).toList();
  }

  Future<List<Contract>> readForPaymentContracts({int limit = 10}) async {
    final db = await instance.database;
    const orderBy = '${ItemContractFields.balanceForPayment} ASC';
    final result =
        await db.query(tableContract, limit: limit, orderBy: orderBy);
    return result.map((json) => Contract.fromJson(json)).toList();
  }

  Future<int> getCountContract() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableContract"));
    return result ?? 0;
  }

  /// Справочник.Товары
  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert(tableProduct, product.toJson());
    product.id = id;
    return product;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(
      tableProduct,
      product.toJson(),
      where: '${ItemProductFields.id} = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableProduct,
      where: '${ItemProductFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProduct() async {
    final db = await instance.database;
    return await db.delete(
      tableProduct,
    );
  }

  Future<Product> readProduct(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableProduct,
      columns: ItemProductFields.values,
      where: '${ItemProductFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      throw Product();
    }
  }

  Future<Product> readProductByUID(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      tableProduct,
      columns: ItemProductFields.values,
      where: '${ItemProductFields.uid} = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      throw Product();
    }
  }

  Future<List<Product>> readAllProducts() async {
    final db = await instance.database;
    const orderBy = '${ItemProductFields.name} ASC';
    final result = await db.query(tableProduct, orderBy: orderBy);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> readProductsByParent(String uidParent) async {
    final db = await instance.database;
    const orderBy = '${ItemProductFields.name} ASC';
    final result = await db.query(tableProduct,
        where: '${ItemProductFields.uidParent} = ?',
        whereArgs: [uidParent],
        orderBy: orderBy);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> readProductsForSearch(String searchString) async {
    final db = await instance.database;
    const orderBy = '${ItemProductFields.name} ASC';
    final result = await db.query(tableProduct,
        where: '${ItemProductFields.name} LIKE ?',
        whereArgs: ['%$searchString%'],
        orderBy: orderBy);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<int> getCountProduct() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableProduct"));
    return result ?? 0;
  }

  /// Справочник.ТипыЦен
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

  Future<int> deleteAllPrice() async {
    final db = await instance.database;
    return await db.delete(
      tablePrice,
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
      throw Price();
    }
  }

  Future<Price> readPriceByUID(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      tablePrice,
      columns: ItemPriceFields.values,
      where: '${ItemPriceFields.uid} = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return Price.fromJson(maps.first);
    } else {
      throw Price();
    }
  }

  Future<List<Price>> readAllPrices() async {
    final db = await instance.database;
    const orderBy = '${ItemPriceFields.name} ASC';
    final result = await db.query(tablePrice, orderBy: orderBy);
    return result.map((json) => Price.fromJson(json)).toList();
  }

  Future<int> getCountPrice() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tablePrice"));
    return result ?? 0;
  }

  /// Справочник.Валюты
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

  Future<int> deleteAllCurrency() async {
    final db = await instance.database;
    return await db.delete(
      tableCurrency,
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
      throw Currency();
    }
  }

  Future<List<Currency>> readAllCurrency() async {
    final db = await instance.database;
    const orderBy = '${ItemCurrencyFields.name} ASC';
    final result = await db.query(tableCurrency, orderBy: orderBy);
    return result.map((json) => Currency.fromJson(json)).toList();
  }

  Future<int> getCountCurrency() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableCurrency"));
    return result ?? 0;
  }

  /// Справочник.ЕдиницыИзмерений
  Future<Unit> createUnit(Unit unit) async {
    final db = await instance.database;
    final id = await db.insert(tableUnit, unit.toJson());
    unit.id = id;
    return unit;
  }

  Future<int> updateUnit(Unit unit) async {
    final db = await instance.database;
    return db.update(
      tableUnit,
      unit.toJson(),
      where: '${ItemUnitFields.id} = ?',
      whereArgs: [unit.id],
    );
  }

  Future<int> deleteUnit(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableUnit,
      where: '${ItemUnitFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllUnit() async {
    final db = await instance.database;
    return await db.delete(
      tableUnit,
    );
  }

  Future<Unit> readUnit(int id) async {
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
      throw Unit();
    }
  }

  Future<List<Unit>> readAllUnit() async {
    final db = await instance.database;
    const orderBy = '${ItemUnitFields.name} ASC';
    final result = await db.query(tableUnit, orderBy: orderBy);
    return result.map((json) => Unit.fromJson(json)).toList();
  }

  Future<int> getCountUnit() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableUnit"));
    return result ?? 0;
  }

  /// Справочник.Склады
  Future<Warehouse> createWarehouse(Warehouse warehouse) async {
    final db = await instance.database;
    final id = await db.insert(tableWarehouse, warehouse.toJson());
    warehouse.id = id;
    return warehouse;
  }

  Future<int> updateWarehouse(Warehouse warehouse) async {
    final db = await instance.database;
    return db.update(
      tableWarehouse,
      warehouse.toJson(),
      where: '${ItemWarehouseFields.id} = ?',
      whereArgs: [warehouse.id],
    );
  }

  Future<int> deleteWarehouse(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableWarehouse,
      where: '${ItemWarehouseFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllWarehouse() async {
    final db = await instance.database;
    return await db.delete(
      tableWarehouse,
    );
  }

  Future<Warehouse> readWarehouse(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableWarehouse,
      columns: ItemWarehouseFields.values,
      where: '${ItemWarehouseFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Warehouse.fromJson(maps.first);
    } else {
      throw Warehouse();
    }
  }

  Future<Warehouse> readWarehouseByUID(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      tableWarehouse,
      columns: ItemWarehouseFields.values,
      where: '${ItemWarehouseFields.uid} = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return Warehouse.fromJson(maps.first);
    } else {
      return Warehouse();
    }
  }

  Future<List<Warehouse>> readAllWarehouse() async {
    final db = await instance.database;
    const orderBy = '${ItemWarehouseFields.name} ASC';
    final result = await db.query(tableWarehouse, orderBy: orderBy);
    return result.map((json) => Warehouse.fromJson(json)).toList();
  }

  Future<int> getCountWarehouse() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableWarehouse"));
    return result ?? 0;
  }

  /// Справочник.Кассы
  Future<Cashbox> createCashbox(Cashbox cashbox) async {
    final db = await instance.database;
    final id = await db.insert(tableCashbox, cashbox.toJson());
    cashbox.id = id;
    return cashbox;
  }

  Future<int> updateCashbox(Cashbox cashbox) async {
    final db = await instance.database;
    return db.update(
      tableCashbox,
      cashbox.toJson(),
      where: '${ItemCashboxFields.id} = ?',
      whereArgs: [cashbox.id],
    );
  }

  Future<int> deleteCashbox(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableCashbox,
      where: '${ItemCashboxFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllCashbox() async {
    final db = await instance.database;
    return await db.delete(
      tableCashbox,
    );
  }

  Future<Cashbox> readCashbox(int id) async {
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

  Future<List<Cashbox>> readAllCashbox() async {
    final db = await instance.database;
    const orderBy = '${ItemCashboxFields.name} ASC';
    final result = await db.query(tableCashbox, orderBy: orderBy);
    return result.map((json) => Cashbox.fromJson(json)).toList();
  }

  Future<int> getCountCashbox() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableCashbox"));
    return result ?? 0;
  }

  /// Документы.ЗаказПокупателя
  Future<OrderCustomer> createOrderCustomer(OrderCustomer orderCustomer,
      List<ItemOrderCustomer> itemsOrderCustomer) async {
    final db = await instance.database;
    try {
      db.transaction((txn) async {
        orderCustomer.id =
            await txn.insert(tableOrderCustomer, orderCustomer.toJson());

        /// Запись ТЧ "Товары"
        for (var itemOrderCustomer in itemsOrderCustomer) {
          itemOrderCustomer.idOrderCustomer = orderCustomer.id;
          txn.insert(tableItemsOrderCustomer, itemOrderCustomer.toJson());
        }
      });
      return orderCustomer;
    } catch (e) {
      throw Exception('Ошибка записи объекта!');
    }
  }

  Future<int> updateOrderCustomer(OrderCustomer orderCustomer,
      List<ItemOrderCustomer> itemsOrderCustomer) async {
    final db = await instance.database;
    int intOperation = 0;
    try {
      db.transaction((txn) async {
        intOperation = intOperation +
            await txn.update(
              tableOrderCustomer,
              orderCustomer.toJson(),
              where: '${OrderCustomerFields.id} = ?',
              whereArgs: [orderCustomer.id],
            );

        /// Очистка ТЧ "Товары"
        txn.delete(
          tableItemsOrderCustomer,
          where: '${ItemOrderCustomerFields.idOrderCustomer} = ?',
          whereArgs: [orderCustomer.id],
        );
        intOperation = intOperation + 1;

        /// Добавление ТЧ "Товары"
        for (var itemOrderCustomer in itemsOrderCustomer) {
          itemOrderCustomer.idOrderCustomer = orderCustomer.id;
          txn.insert(tableItemsOrderCustomer, itemOrderCustomer.toJson());
          intOperation = intOperation + 1;
        }
      });
      return intOperation;
    } catch (e) {
      throw Exception('Ошибка записи объекта!');
    }
  }

  Future<int> deleteOrderCustomer(int id) async {
    final db = await instance.database;
    try {
      db.transaction((txn) async {
        txn.delete(
          tableOrderCustomer,
          where: '${OrderCustomerFields.id} = ?',
          whereArgs: [id],
        );
        txn.delete(
          tableItemsOrderCustomer,
          where: '${ItemOrderCustomerFields.id} = ?',
          whereArgs: [id],
        );
      });
      return 1;
    } catch (e) {
      throw Exception('Ошибка удаления объекта с ID: $id!');
    }
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
      throw OrderCustomer();
    }
  }

  Future<OrderCustomer> readOrderCustomerByUID(String uid) async {
    final db = await instance.database;
    final maps = await db.query(
      tableOrderCustomer,
      columns: OrderCustomerFields.values,
      where: '${OrderCustomerFields.uid} = ?',
      whereArgs: [uid],
    );

    if (maps.isNotEmpty) {
      return OrderCustomer.fromJson(maps.first);
    } else {
      throw OrderCustomer();
    }
  }

  Future<List<ItemOrderCustomer>> readItemsOrderCustomer(
      int idOrderCustomer) async {
    final db = await instance.database;
    if (!db.isOpen) {
      DatabaseHelper._init();
    }
    const orderBy = '${ItemOrderCustomerFields.name} ASC';
    final result = await db.query(tableItemsOrderCustomer,
        where: '${ItemOrderCustomerFields.idOrderCustomer} = ?',
        whereArgs: [idOrderCustomer],
        orderBy: orderBy);

    return result.map((json) => ItemOrderCustomer.fromJson(json)).toList();
  }

  Future<List<OrderCustomer>> readAllNewOrderCustomer() async {
    final db = await instance.database;
    if (!db.isOpen) {
      DatabaseHelper._init();
    }
    String orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [1],
        orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<List<OrderCustomer>> readAllSendOrderCustomer() async {
    final db = await instance.database;
    String orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [2],
        orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<List<OrderCustomer>> readAllTrashOrderCustomer() async {
    final db = await instance.database;
    String orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?',
        whereArgs: [3],
        orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<int> getCountOrderCustomer() async {
    final db = await instance.database;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tableOrderCustomer"));
    return result ?? 0;
  }

  Future<int> getCountNewOrderCustomer() async {
    final db = await instance.database;
    final result = await db.query(tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?', whereArgs: [0]);
    return result.map((json) => OrderCustomer.fromJson(json)).toList().length;
  }

  Future<int> getCountSendOrderCustomer() async {
    final db = await instance.database;
    final result = await db.query(tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?', whereArgs: [1]);
    return result.map((json) => OrderCustomer.fromJson(json)).toList().length;
  }

  Future<int> getCountTrashOrderCustomer() async {
    final db = await instance.database;
    final result = await db.query(tableOrderCustomer,
        where: '${OrderCustomerFields.status} = ?', whereArgs: [2]);
    return result.map((json) => OrderCustomer.fromJson(json)).toList().length;
  }

  /// РегистрНакопления.Взаиморасчеты
  Future<AccumPartnerDept> createPartnerDept(
      AccumPartnerDept accumDeptPartner) async {
    final db = await instance.database;
    final id =
        await db.insert(tableAccumPartnerDebts, accumDeptPartner.toJson());
    accumDeptPartner.id = id;
    return accumDeptPartner;
  }

  Future<int> updatePartnerDept(AccumPartnerDept accumDeptPartner) async {
    final db = await instance.database;
    return db.update(
      tableAccumPartnerDebts,
      accumDeptPartner.toJson(),
      where: '${ItemAccumPartnerDeptFields.id} = ?',
      whereArgs: [accumDeptPartner.id],
    );
  }

  Future<int> deletePartnerDept(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableAccumPartnerDebts,
      where: '${ItemAccumPartnerDeptFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllPartnerDept() async {
    final db = await instance.database;
    return await db.delete(
      tableAccumPartnerDebts,
    );
  }

  Future<AccumPartnerDept> readPartnerDept(
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

  /// РегистрНакопления.Цены
  Future<AccumProductPrice> createProductPrice(
      AccumProductPrice accumProductPrice) async {
    final db = await instance.database;
    final id =
        await db.insert(tableAccumProductPrices, accumProductPrice.toJson());
    accumProductPrice.id = id;
    return accumProductPrice;
  }

  Future<int> updateProductPrice(AccumProductPrice accumProductPrice) async {
    final db = await instance.database;
    return db.update(
      tableAccumProductPrices,
      accumProductPrice.toJson(),
      where: '${ItemAccumProductPricesFields.id} = ?',
      whereArgs: [accumProductPrice.id],
    );
  }

  Future<int> deleteProductPrice(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableAccumProductPrices,
      where: '${ItemAccumProductPricesFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProductPrice() async {
    final db = await instance.database;
    return await db.delete(
      tableAccumProductPrices,
    );
  }

  Future<double> readProductPrice(
      {required String uidPrice, required String uidProduct}) async {
    final db = await instance.database;
    final maps = await db.query(
      tableAccumProductPrices,
      columns: ItemAccumProductPricesFields.values,
      where:
          '${ItemAccumProductPricesFields.uidPrice} = ? AND ${ItemAccumProductPricesFields.uidProduct} = ?',
      whereArgs: [uidPrice, uidProduct],
    );

    if (maps.isNotEmpty) {
      return AccumProductPrice.fromJson(maps.first).price;
    } else {
      return 0.0;
    }
  }

  /// РегистрНакопления.ОстаткиНаСкладах
  Future<AccumProductRest> createProductRest(
      AccumProductRest accumProductRest) async {
    final db = await instance.database;
    final id =
        await db.insert(tableAccumProductRests, accumProductRest.toJson());
    accumProductRest.id = id;
    return accumProductRest;
  }

  Future<int> updateProductRest(AccumProductRest accumProductRest) async {
    final db = await instance.database;
    return db.update(
      tableAccumProductRests,
      accumProductRest.toJson(),
      where: '${ItemAccumProductRestsFields.id} = ?',
      whereArgs: [accumProductRest.id],
    );
  }

  Future<int> deleteProductRest(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableAccumProductRests,
      where: '${ItemAccumProductRestsFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllProductRest() async {
    final db = await instance.database;
    return await db.delete(
      tableAccumProductRests,
    );
  }

  Future<double> readProductRest(
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
}
