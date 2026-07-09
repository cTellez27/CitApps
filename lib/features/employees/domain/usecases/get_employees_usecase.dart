import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployeesUseCase {
  final EmployeeRepository repository;

  const GetEmployeesUseCase(this.repository);

  Future<Either<Failure, List<EmployeeEntity>>> execute(String barbershopId) {
    return repository.getEmployees(barbershopId);
  }
}
