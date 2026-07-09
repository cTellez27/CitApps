import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../entities/appointment_service_entity.dart';
import '../repositories/appointment_repository.dart';

class CreateAppointmentUseCase {
  final AppointmentRepository repository;

  const CreateAppointmentUseCase(this.repository);

  Future<Either<Failure, AppointmentEntity>> execute({
    required AppointmentEntity appointment,
    required List<AppointmentServiceEntity> services,
  }) {
    return repository.createAppointment(appointment, services);
  }
}
