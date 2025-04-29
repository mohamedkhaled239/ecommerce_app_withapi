import 'package:ecommerce_task/core/errors/exceptions.dart';
import 'package:ecommerce_task/features/cart/data/model/cart_model.dart';
import 'package:ecommerce_task/features/product/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class CartLocalDataSource {
  Future<void> addToCart(ProductModel product);
  Future<List<CartModel>> getCartItems();
  Future<void> removeFromCart(int productId);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final Database database;

  CartLocalDataSourceImpl({required this.database});

  @override
  Future<void> addToCart(ProductModel product) async {
    try {
      await database.insert(
        'cart',
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to add product to cart');
    }
  }

  @override
  Future<List<CartModel>> getCartItems() async {
    try {
      final List<Map<String, dynamic>> maps = await database.query('cart');
      return List.generate(maps.length, (i) {
        return CartModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException(message: 'Failed to get cart items');
    }
  }

  @override
  Future<void> removeFromCart(int productId) async {
    try {
      await database.delete('cart', where: 'id = ?', whereArgs: [productId]);
    } catch (e) {
      throw CacheException(message: 'Failed to remove product from cart');
    }
  }
}
