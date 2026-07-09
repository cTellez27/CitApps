import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_service_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentServicesUseCase {
  final AppointmentRepository repository;

  const GetAppointmentServicesUseCase(this.repository);

  Future<Either<Failure, List<AppointmentServiceEntity>>> execute(String appointmentId) {
    return repository.getAppointmentServices(appointmentId);
  }
}
