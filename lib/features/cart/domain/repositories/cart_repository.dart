import 'package:dartz/dartz.dart';
import 'package:ecommerce_task/features/product/data/models/product_model.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';

abstract class CartRepository {
  Future<Either<Failure, void>> addToCart(ProductModel product);
  Future<Either<Failure, List<Cart>>> getCartItems();
  Future<Either<Failure, void>> removeFromCart(int productId);
}
