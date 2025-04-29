import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic data;

  const Failure({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'Failure: $message';

  @override
  List<Object?> get props => [message, statusCode, data];
}

/// Failure for server errors
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.statusCode,
    super.data,
  });
}

/// Failure for cache errors
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.statusCode,
    super.data,
  });
}

/// Failure for network connectivity errors
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.statusCode,
    super.data,
  });
}
