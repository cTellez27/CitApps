import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class CreateEmployeeUseCase {
  final EmployeeRepository repository;

  const CreateEmployeeUseCase(this.repository);

  Future<Either<Failure, EmployeeEntity>> execute(EmployeeEntity employee) {
    return repository.createEmployee(employee);
  }
}
