import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
import '../models/product_table.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<Product> products);
  Future<List<Product>> getLastProducts();
  Future<Product?> getProductById(int id);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Database database;
  bool _isInitialized = false;

  ProductLocalDataSourceImpl({required this.database}) {
    _initialize();
  }

  @override
  Future<void> _initialize() async {
    try {
      // Verify tables exist
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='products'",
      );
      _isInitialized = tables.isNotEmpty;
      if (!_isInitialized) {
        await database.execute('''
          CREATE TABLE IF NOT EXISTS products (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            image TEXT NOT NULL,
            rate REAL NOT NULL,
            count INTEGER NOT NULL
          )
        ''');
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('Table initialization error: $e');
      _isInitialized = false;
    }
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    if (!_isInitialized) {
      await _initialize();
    }

    try {
      await database.transaction((txn) async {
        await txn.delete('products');

        for (final product in products) {
          final model = ProductModel.fromEntity(product);
          await txn.insert(
            'products',
            model.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      debugPrint('Successfully cached ${products.length} products');
    } catch (e, stackTrace) {
      debugPrint('Error caching products: $e');
      debugPrint(stackTrace.toString());
      throw CacheException(
        message: 'Failed to cache products',
        data: e.toString(),
      );
    }
  }

  @override
  Future<List<Product>> getLastProducts() async {
    try {
      final maps = await database.query(ProductTable.tableName);
      if (maps.isEmpty) return [];

      return maps
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      debugPrint('Error getting cached products: $e');
      throw CacheException(
        message: 'Failed to get cached products',
        data: e.toString(),
      );
    }
  }

  @override
  Future<Product?> getProductById(int id) async {
    try {
      final maps = await database.query(
        ProductTable.tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return ProductModel.fromJson(maps.first).toEntity();
    } catch (e) {
      debugPrint('Error getting product by id: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await database.delete(ProductTable.tableName);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      throw CacheException(
        message: 'Failed to clear cache',
        data: e.toString(),
      );
    }
  }
}
