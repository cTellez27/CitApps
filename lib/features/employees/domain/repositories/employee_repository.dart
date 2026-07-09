import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/employee_entity.dart';
import '../entities/employee_schedule_entity.dart';

/// Contract definition for Employee repository.
///
/// Manages staff profiles, commissions, and schedules.
abstract class EmployeeRepository {
  /// Fetches staff list for a specific barbershop.
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees(String barbershopId);

  /// Registers a new staff member profile.
  Future<Either<Failure, EmployeeEntity>> createEmployee(EmployeeEntity employee);

  /// Updates details of a staff member.
  Future<Either<Failure, EmployeeEntity>> updateEmployee(EmployeeEntity employee);

  /// Deactivates (soft deletes) a staff member.
  Future<Either<Failure, void>> deleteEmployee(String id);

  /// Fetches custom schedule for an employee.
  Future<Either<Failure, List<EmployeeScheduleEntity>>> getEmployeeSchedule(String employeeId);

  /// Updates work schedules for an employee.
  Future<Either<Failure, List<EmployeeScheduleEntity>>> updateEmployeeSchedule(
    List<EmployeeScheduleEntity> schedules,
  );
}
