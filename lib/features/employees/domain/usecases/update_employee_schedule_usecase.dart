import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_schedule_entity.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployeeScheduleUseCase {
  final EmployeeRepository repository;

  const UpdateEmployeeScheduleUseCase(this.repository);

  Future<Either<Failure, List<EmployeeScheduleEntity>>> execute(
    List<EmployeeScheduleEntity> schedules,
  ) {
    return repository.updateEmployeeSchedule(schedules);
  }
}
