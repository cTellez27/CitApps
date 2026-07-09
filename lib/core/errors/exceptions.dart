/// Custom exception types for CitApps.
///
/// These exceptions are thrown by datasources and caught
/// by repository implementations to return [Failure] objects.
library;

/// Exception thrown when a server (Supabase) request fails.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

/// Exception thrown when local cache operations fail.
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Exception thrown when authentication fails.
class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() => 'AuthException(message: $message)';
}

/// Exception thrown when a network connection is unavailable.
class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}

/// Exception thrown when a requested resource is not found.
class NotFoundException implements Exception {
  final String message;

  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException(message: $message)';
}

/// Exception thrown when a user lacks permission for an operation.
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({
    this.message = 'No tienes permisos para realizar esta acción',
  });

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}
