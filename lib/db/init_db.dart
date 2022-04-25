import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/import/import_db.dart';

/// Типы данных таблиц базы данных
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const textType = 'TEXT NOT NULL';
const realType = 'REAL NOT NULL';
const integerType = 'INTEGER NOT NULL';

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
        _database = await _initDB('WPSalesDB2.db');
        return _database!;
      }
    }
    _database = await _initDB('WPSalesDB2.db');
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

    /// Справочник.Магазин (Торговая точка)
    await createTableStore(db);

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

    /// РегистрСведений.ПроцентыВозвратовКонтрагента
    await createTableInfoRgReturnPercents(db);
  }

  Future close() async {
    final db = await instance.database;
    _database = null;
    db.close();
  }
}
