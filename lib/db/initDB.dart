import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/db/dbOrderCustomer.dart';
import 'package:wp_sales/models/orderCustomer.dart';

class WPSalesDatabase {
  static final WPSalesDatabase instance = WPSalesDatabase._init();

  static Database? _database;

  WPSalesDatabase._init();

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

    /// Справочник "Номенклатура"
    await db.execute('''
    CREATE TABLE $tableDocOrderCustomer (    
      ${DocOrderCustomerFields.id} $idType, 
      ${DocOrderCustomerFields.isDeleted} $integerType,
      ${DocOrderCustomerFields.date} $textType,
      ${DocOrderCustomerFields.uid} $textType,
      ${DocOrderCustomerFields.uidOrganization} $textType,
      ${DocOrderCustomerFields.uidPartner} $textType,
      ${DocOrderCustomerFields.namePartner} $textType,
      ${DocOrderCustomerFields.uidContract} $textType,  
      ${DocOrderCustomerFields.uidPrice} $textType,
      ${DocOrderCustomerFields.sum} $realType,
      ${DocOrderCustomerFields.dateSending} $textType,
      ${DocOrderCustomerFields.datePaying} $textType
      ${DocOrderCustomerFields.sendYesTo1C} $integerType
      ${DocOrderCustomerFields.sendNoTo1C} $integerType
      ${DocOrderCustomerFields.dateSendingTo1C} $textType
      ${DocOrderCustomerFields.numberFrom1C} $textType
      )
    ''');
  }

  Future<OrderCustomer> create(OrderCustomer orderCustomer) async {
    final db = await instance.database;

    final id = await db.insert(tableDocOrderCustomer, orderCustomer.toJson());
    orderCustomer.id = id;
    return orderCustomer;
  }

  Future<OrderCustomer> read(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableDocOrderCustomer,
      columns: DocOrderCustomerFields.values,
      where: '${DocOrderCustomerFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return OrderCustomer.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<OrderCustomer>> readAll() async {
    final db = await instance.database;

    const orderBy = '${DocOrderCustomerFields.date} ASC';
    final result = await db.query(tableDocOrderCustomer, orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<int> update(OrderCustomer orderCustomer) async {
    final db = await instance.database;

    return db.update(
      tableDocOrderCustomer,
      orderCustomer.toJson(),
      where: '${DocOrderCustomerFields.id} = ?',
      whereArgs: [orderCustomer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableDocOrderCustomer,
      where: '${DocOrderCustomerFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}