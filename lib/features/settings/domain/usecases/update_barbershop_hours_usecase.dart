import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/barbershop_hours_entity.dart';
import '../repositories/settings_repository.dart';

class UpdateBarbershopHoursUseCase {
  final SettingsRepository repository;

  const UpdateBarbershopHoursUseCase(this.repository);

  Future<Either<Failure, List<BarbershopHoursEntity>>> execute(
    List<BarbershopHoursEntity> hours,
  ) {
    return repository.updateBarbershopHours(hours);
  }
}
