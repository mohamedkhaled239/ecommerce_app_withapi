import 'package:dartz/dartz.dart';
import 'package:ecommerce_task/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getAllProducts();
        try {
          await localDataSource.cacheProducts(remoteProducts);
        } catch (e) {
          debugPrint('Caching failed but continuing: $e');
        }
        return Right(remoteProducts);
      } on ServerException catch (es) {
        debugPrint('Error fetching right details: $es');

        return Left(ServerFailure());
      }
    } else {
      try {
        final localProducts = await localDataSource.getLastProducts();
        if (localProducts.isEmpty) {
          return Left(CacheFailure());
        }
        return Right(localProducts);
      } on CacheException catch (ee) {
        debugPrint('Error fetching right details: $ee');

        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProductDetails(int id) async {
    try {
      debugPrint('Attempting to fetch product details for ID: $id');

      try {
        final cachedProduct = await localDataSource.getProductById(id);
        if (cachedProduct != null) {
          debugPrint('Returning product from cache');
          return Right(cachedProduct);
        }
      } catch (e) {
        debugPrint('Cache read error: $e');
      }

      if (!await networkInfo.isConnected) {
        debugPrint('No internet connection');
        return Left(NetworkFailure());
      }

      debugPrint('Fetching product from API');
      final remoteProduct = await remoteDataSource.getProductById(id);

      try {
        await localDataSource.cacheProducts([remoteProduct]);
        debugPrint('Product cached successfully');
      } catch (e) {
        debugPrint('Caching failed but continuing: $e');
      }

      return Right(remoteProduct);
    } on ServerException catch (e) {
      debugPrint('ServerException: ${e.message}');
      return Left(ServerFailure());
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return Left(ServerFailure());
    }
  }
}
