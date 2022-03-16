import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_accum_product_prices.dart';
import 'package:wp_sales/db/db_accum_product_rests.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/db/db_ref_currency.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/db/db_ref_price.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/db/db_ref_unit.dart';
import 'package:wp_sales/db/db_ref_warehouse.dart';

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
}
