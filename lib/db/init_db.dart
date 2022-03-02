import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wp_sales/models/order_customer.dart';

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
    CREATE TABLE $tableOrderCustomer (    
      ${OrderCustomerFields.id} $idType, 
      ${OrderCustomerFields.isDeleted} $integerType,
      ${OrderCustomerFields.date} $textType,
      ${OrderCustomerFields.uid} $textType,
      ${OrderCustomerFields.uidOrganization} $textType,
      ${OrderCustomerFields.uidPartner} $textType,
      ${OrderCustomerFields.namePartner} $textType,
      ${OrderCustomerFields.uidContract} $textType,
      ${OrderCustomerFields.nameContract} $textType,  
      ${OrderCustomerFields.uidPrice} $textType,
      ${OrderCustomerFields.sum} $realType,
      ${OrderCustomerFields.dateSending} $textType,
      ${OrderCustomerFields.datePaying} $textType
      ${OrderCustomerFields.sendYesTo1C} $integerType
      ${OrderCustomerFields.sendNoTo1C} $integerType
      ${OrderCustomerFields.dateSendingTo1C} $textType
      ${OrderCustomerFields.numberFrom1C} $textType
      )
    ''');
  }

  Future<OrderCustomer> create(OrderCustomer orderCustomer) async {
    final db = await instance.database;

    final id = await db.insert(tableOrderCustomer, orderCustomer.toJson());
    orderCustomer.id = id;
    return orderCustomer;
  }

  Future<OrderCustomer> read(int id) async {
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
      throw Exception('ID $id not found');
    }
  }

  Future<List<OrderCustomer>> readAll() async {
    final db = await instance.database;

    const orderBy = '${OrderCustomerFields.date} ASC';
    final result = await db.query(tableOrderCustomer, orderBy: orderBy);

    return result.map((json) => OrderCustomer.fromJson(json)).toList();
  }

  Future<int> update(OrderCustomer orderCustomer) async {
    final db = await instance.database;

    return db.update(
      tableOrderCustomer,
      orderCustomer.toJson(),
      where: '${OrderCustomerFields.id} = ?',
      whereArgs: [orderCustomer.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableOrderCustomer,
      where: '${OrderCustomerFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}