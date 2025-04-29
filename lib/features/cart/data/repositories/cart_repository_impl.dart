import 'package:dartz/dartz.dart';
import 'package:ecommerce_task/features/product/data/models/product_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';

import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> addToCart(ProductModel product) async {
    try {
      await localDataSource.addToCart(product);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Cart>>> getCartItems() async {
    try {
      final cartItems = await localDataSource.getCartItems();
      return Right(cartItems.cast<Cart>());
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(int productId) async {
    try {
      await localDataSource.removeFromCart(productId);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
