import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/barbershop_entity.dart';
import '../entities/barbershop_hours_entity.dart';

/// Contract definition for Settings repository.
///
/// Handles general business configurations and operational calendars.
abstract class SettingsRepository {
  /// Fetches details for a specific barbershop.
  Future<Either<Failure, BarbershopEntity>> getBarbershop(String id);

  /// Updates details for a specific barbershop.
  Future<Either<Failure, BarbershopEntity>> updateBarbershop(BarbershopEntity barbershop);

  /// Fetches daily operational schedule for a specific barbershop.
  Future<Either<Failure, List<BarbershopHoursEntity>>> getBarbershopHours(String barbershopId);

  /// Updates daily operational schedules.
  Future<Either<Failure, List<BarbershopHoursEntity>>> updateBarbershopHours(
    List<BarbershopHoursEntity> hours,
  );
}
