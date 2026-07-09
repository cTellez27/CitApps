import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/barbershop_hours_entity.dart';
import '../repositories/settings_repository.dart';

class GetBarbershopHoursUseCase {
  final SettingsRepository repository;

  const GetBarbershopHoursUseCase(this.repository);

  Future<Either<Failure, List<BarbershopHoursEntity>>> execute(String barbershopId) {
    return repository.getBarbershopHours(barbershopId);
  }
}
