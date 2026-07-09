import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/service_repository.dart';

class UpdateServiceEmployeesUseCase {
  final ServiceRepository repository;

  const UpdateServiceEmployeesUseCase(this.repository);

  Future<Either<Failure, void>> execute(String serviceId, List<String> employeeIds) {
    return repository.updateServiceEmployees(serviceId, employeeIds);
  }
}
