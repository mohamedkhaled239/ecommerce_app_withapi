import 'package:dio/dio.dart';

/// Base class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppException({required this.message, this.statusCode, this.data});

  @override
  String toString() {
    return 'AppException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

/// Exception thrown when server requests fail
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode,
    super.data,
  });

  factory ServerException.fromDioException(DioException dioException) {
    try {
      return ServerException(
        message: _parseDioErrorMessage(dioException),
        statusCode: dioException.response?.statusCode,
        data: dioException.response?.data,
      );
    } catch (e) {
      return const ServerException(message: 'Unknown server error');
    }
  }

  static String _parseDioErrorMessage(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout with server';
      case DioExceptionType.sendTimeout:
        return 'Send timeout with server';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout with server';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.badResponse:
        return _parseBadResponse(dioException.response);
      case DioExceptionType.cancel:
        return 'Request to server was cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error occurred';
      case DioExceptionType.unknown:
        return 'Unknown error occurred: ${dioException.message}';
    }
  }

  static String _parseBadResponse(Response? response) {
    try {
      if (response == null) return 'Bad response: null';

      final statusCode = response.statusCode;
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data['message'] ??
            data['error'] ??
            'Server responded with status $statusCode';
      }

      return 'Server responded with status $statusCode';
    } catch (e) {
      return 'Failed to parse server error';
    }
  }
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.statusCode,
    super.data,
  });
}

/// Exception thrown when there's no internet connection
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.statusCode,
    super.data,
  });
}
