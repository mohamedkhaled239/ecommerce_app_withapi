import 'package:dio/dio.dart';
import 'package:ecommerce_task/core/errors/exceptions.dart';

class DioClient {
  final Dio dio;

  DioClient({required this.dio}) {
    dio.options.baseUrl = 'https://fakestoreapi.com';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.responseType = ResponseType.json;
  }

  Future<Response> get(String path) async {
    try {
      final response = await dio.get(path);
      return response;
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Server error');
    }
  }
}
