import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Contract definition for Authentication repository.
///
/// Implemented in Data layer, accessed by Domain use cases.
abstract class AuthRepository {
  /// Sign in user with email and password.
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  });

  /// Sign up a new Owner user with email, password, and full name.
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign out the current logged-in user.
  Future<Either<Failure, void>> signOut();

  /// Send password reset link to user email.
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Retrieves the current authenticated user's profile details.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Registers a new barbershop for the current user during onboarding.
  Future<Either<Failure, UserEntity>> createBarbershop({
    required String name,
    required String phone,
    required String address,
  });

  /// Stream of Auth user changes to react to login/logout events.
  Stream<UserEntity?> get onAuthStateChanged;
}
