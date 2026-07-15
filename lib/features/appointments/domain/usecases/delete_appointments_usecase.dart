import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';

class DeleteAppointmentsUseCase {
  final AppointmentRepository repository;

  const DeleteAppointmentsUseCase(this.repository);

  Future<Either<Failure, void>> execute(List<String> ids) {
    return repository.deleteAppointments(ids);
  }
}
