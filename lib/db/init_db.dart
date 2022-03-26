import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/db_accum_partner_depts.dart';
import 'package:wp_sales/db/db_accum_product_prices.dart';
import 'package:wp_sales/db/db_accum_product_rests.dart';
import 'package:wp_sales/db/db_doc_incoming_cash_order.dart';
import 'package:wp_sales/db/db_doc_order_customer.dart';
import 'package:wp_sales/db/db_doc_return_order_customer.dart';
import 'package:wp_sales/db/db_ref_cashbox.dart';
import 'package:wp_sales/db/db_ref_contract.dart';
import 'package:wp_sales/db/db_ref_currency.dart';
import 'package:wp_sales/db/db_ref_organization.dart';
import 'package:wp_sales/db/db_ref_partner.dart';
import 'package:wp_sales/db/db_ref_price.dart';
import 'package:wp_sales/db/db_ref_product.dart';
import 'package:wp_sales/db/db_ref_product_characteristic.dart';
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
        _database = await _initDB('WPSalesDB4.db');
        return _database!;
      }
    }
    _database = await _initDB('WPSalesDB4.db');
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

    /// Документ.ЗаказПокупателя
    await createTableOrderCustomer(db);

    /// Документ.ЗаказПокупателя - ТЧ "Товары" (№1)
    await createTableItemOrderCustomer(db);

    /// Документ.ВозвратТоваровОтПокупателя
    await createTableReturnOrderCustomer(db);

    /// Документ.ВозвратТоваровОтПокупателя  - ТЧ "Товары" (№1)
    await createTableItemReturnOrderCustomer(db);

    /// Документ.ПриходныйКассовыйОрдер
    await createTableIncomingCashOrder(db);

    /// Справочник.Организации
    await createTableOrganization(db);

    /// Справочник.Партнеры
    await createTablePartner(db);

    /// Справочник.ДоговорыПартнеров (Контракты)
    await createTableContract(db);

    /// Справочник.ТипЦенНоменклатуры
    await createTablePrice(db);

    /// Справочник.Валюты
    await createTableCurrency(db);

    /// Справочник.Кассы
    await createTableCashbox(db);

    /// Справочник.ЕдиницыИзмерения
    await createTableUnit(db);

    /// Справочник.Склады
    await createTableWarehouse(db);

    /// Справочник.Номенклатура
    await createTableProduct(db);

    /// Справочник.ХарактеристикиНоменклатуры
    await createTableProductCharacteristic(db);

    /// РегистрНакопления.ВзаиморасчетыСКонтрагентами (Партнерами)
    await createTableAccumPartnerDebts(db);

    /// РегистрНакопления.ЦеныНоменклатуры
    await createTableAccumProductPrices(db);

    /// РегистрНакопления.ОстаткиНаСкладах
    await createTableAccumProductRests(db);
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }
}
