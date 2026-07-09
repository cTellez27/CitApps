import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/appointment_repository.dart';

class CancelAppointmentUseCase {
  final AppointmentRepository repository;

  const CancelAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) {
    return repository.updateAppointmentStatus(id, 'cancelled');
  }
}
