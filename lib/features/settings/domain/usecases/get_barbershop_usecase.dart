import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/barbershop_entity.dart';
import '../repositories/settings_repository.dart';

class GetBarbershopUseCase {
  final SettingsRepository repository;

  const GetBarbershopUseCase(this.repository);

  Future<Either<Failure, BarbershopEntity>> execute(String id) {
    return repository.getBarbershop(id);
  }
}
