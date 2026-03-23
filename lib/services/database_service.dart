import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shopping_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService({String? dbPath}) {
    if (dbPath != null) _instance._dbPath = dbPath;
    return _instance;
  }
  DatabaseService._internal();

  Database? _database;
  String? _dbPath;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = _dbPath ?? join(await getDatabasesPath(), 'shoppermost.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE shopping_items(id TEXT PRIMARY KEY, text TEXT, isInCart INTEGER)',
        );
      },
    );
  }

  Future<void> insertItems(List<ShoppingItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert(
        'shopping_items',
        {
          'id': item.id,
          'text': item.text,
          'isInCart': item.isInCart ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<ShoppingItem>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('shopping_items');
    return List.generate(maps.length, (i) {
      return ShoppingItem(
        id: maps[i]['id'],
        text: maps[i]['text'],
        isInCart: maps[i]['isInCart'] == 1,
      );
    });
  }

  Future<void> clearItems() async {
    final db = await database;
    await db.delete('shopping_items');
  }

  Future<void> updateItem(ShoppingItem item) async {
    final db = await database;
    await db.update(
      'shopping_items',
      {
        'isInCart': item.isInCart ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}
