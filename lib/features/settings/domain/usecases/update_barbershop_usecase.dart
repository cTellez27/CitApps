import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/barbershop_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateBarbershopUseCase {
  final SettingsRepository repository;

  const UpdateBarbershopUseCase(this.repository);

  Future<Either<Failure, BarbershopEntity>> execute(BarbershopEntity barbershop) {
    return repository.updateBarbershop(barbershop);
  }
}
