import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> execute({required String email}) {
    return repository.resetPassword(email: email);
  }
}
