import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class CreateBarbershopUseCase {
  final AuthRepository repository;

  const CreateBarbershopUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute({
    required String name,
    required String phone,
    required String address,
  }) {
    return repository.createBarbershop(
      name: name,
      phone: phone,
      address: address,
    );
  }
}
