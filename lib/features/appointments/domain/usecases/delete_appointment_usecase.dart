import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';

class DeleteAppointmentUseCase {
  final AppointmentRepository repository;

  const DeleteAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) {
    return repository.deleteAppointment(id);
  }
}
