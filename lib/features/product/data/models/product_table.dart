import 'package:sqflite/sqflite.dart';

class ProductTable {
  static const String tableName = 'cached_products';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnPrice = 'price';
  static const String columnDescription = 'description';
  static const String columnCategory = 'category';
  static const String columnImage = 'image';
  static const String columnRate = 'rate';
  static const String columnCount = 'count';

  static Future<void> createTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnPrice REAL NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnImage TEXT NOT NULL,
        $columnRate REAL NOT NULL,
        $columnCount INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> deleteTable(Database database) async {
    await database.execute('DROP TABLE IF EXISTS $tableName');
  }
}
