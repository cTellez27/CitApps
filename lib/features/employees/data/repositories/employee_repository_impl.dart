import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/entities/employee_schedule_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';
import '../models/employee_model.dart';
import '../models/employee_schedule_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  const EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getEmployees(String barbershopId) async {
    try {
      final models = await remoteDataSource.getEmployees(barbershopId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> createEmployee(EmployeeEntity employee) async {
    try {
      final model = EmployeeModel.fromEntity(employee);
      final created = await remoteDataSource.createEmployee(model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> updateEmployee(EmployeeEntity employee) async {
    try {
      final model = EmployeeModel.fromEntity(employee);
      final updated = await remoteDataSource.updateEmployee(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(String id) async {
    try {
      await remoteDataSource.deleteEmployee(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeScheduleEntity>>> getEmployeeSchedule(
    String employeeId,
  ) async {
    try {
      final models = await remoteDataSource.getEmployeeSchedule(employeeId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeScheduleEntity>>> updateEmployeeSchedule(
    List<EmployeeScheduleEntity> schedules,
  ) async {
    try {
      final models = schedules.map((s) => EmployeeScheduleModel.fromEntity(s)).toList();
      final updated = await remoteDataSource.updateEmployeeSchedule(models);
      return Right(updated.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
