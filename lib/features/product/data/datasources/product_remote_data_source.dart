import 'package:dio/dio.dart';
import 'package:ecommerce_task/core/errors/exceptions.dart';
import 'package:ecommerce_task/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getAllProducts();
  Future<Product> getProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await dioClient.get('/products');
      return (response.data as List)
          .map((product) => ProductModel.fromJson(product).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ServerException(message: 'Failed to fetch products: ${e.message}');
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      debugPrint('Fetching product from API for ID: $id');
      final response = await dioClient.get('/products/$id');

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('API response: ${response.data}');
        return ProductModel.fromJson(response.data).toEntity();
      } else {
        throw ServerException(
          message: 'Product not found',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      throw ServerException(
        message:
            e.response?.data?['message'] ?? 'Failed to fetch product details',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw ServerException(message: 'Unexpected error occurred');
    }
  }
}
