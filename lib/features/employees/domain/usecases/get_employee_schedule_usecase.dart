import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_schedule_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeScheduleUseCase {
  final EmployeeRepository repository;

  const GetEmployeeScheduleUseCase(this.repository);

  Future<Either<Failure, List<EmployeeScheduleEntity>>> execute(String employeeId) {
    return repository.getEmployeeSchedule(employeeId);
  }
}
