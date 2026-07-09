import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployeeUseCase {
  final EmployeeRepository repository;

  const UpdateEmployeeUseCase(this.repository);

  Future<Either<Failure, EmployeeEntity>> execute(EmployeeEntity employee) {
    return repository.updateEmployee(employee);
  }
}
