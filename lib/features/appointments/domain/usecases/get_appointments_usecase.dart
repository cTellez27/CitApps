import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentsUseCase {
  final AppointmentRepository repository;

  const GetAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> execute(
    String barbershopId,
    DateTime date,
  ) {
    return repository.getAppointments(barbershopId, date);
  }
}
