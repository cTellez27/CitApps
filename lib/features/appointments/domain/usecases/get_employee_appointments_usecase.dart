import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class GetEmployeeAppointmentsUseCase {
  final AppointmentRepository repository;

  const GetEmployeeAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> execute(
    String employeeId,
    DateTime date,
  ) {
    return repository.getEmployeeAppointments(employeeId, date);
  }
}
