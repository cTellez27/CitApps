import 'package:equatable/equatable.dart';

/// Base failure class for domain layer error handling.
///
/// Failures are returned by repositories via [Either<Failure, T>]
/// to represent errors without throwing exceptions.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Failure caused by a server/backend error.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure caused by a local cache error.
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Failure caused by an authentication error.
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Failure caused by no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Sin conexión a internet. Verifica tu red.',
  });
}

/// Failure caused by a resource not being found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

/// Failure caused by insufficient permissions.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'No tienes permisos para realizar esta acción',
  });
}

/// Failure caused by invalid input data.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
