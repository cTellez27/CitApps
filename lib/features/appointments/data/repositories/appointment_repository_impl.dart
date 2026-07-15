import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_service_entity.dart';
import '../../domain/entities/appointment_product_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';
import '../models/appointment_service_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  const AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(
    String barbershopId,
    DateTime date,
  ) async {
    try {
      final models = await remoteDataSource.getAppointments(barbershopId, date);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
    List<AppointmentServiceEntity> services,
  ) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      final serviceModels =
          services.map((s) => AppointmentServiceModel.fromEntity(s)).toList();
      final created = await remoteDataSource.createAppointment(model, serviceModels);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppointmentStatus(String id, String status) async {
    try {
      await remoteDataSource.updateAppointmentStatus(id, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getEmployeeAppointments(
    String employeeId,
    DateTime date,
  ) async {
    try {
      final models = await remoteDataSource.getEmployeeAppointments(employeeId, date);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentServiceEntity>>> getAppointmentServices(
    String appointmentId,
  ) async {
    try {
      final models = await remoteDataSource.getAppointmentServices(appointmentId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExtraService(
      String appointmentId, String serviceId, double price) async {
    try {
      await remoteDataSource.addExtraService(appointmentId, serviceId, price);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExtraProduct(
      String appointmentId, String productId, double price, int quantity) async {
    try {
      await remoteDataSource.addExtraProduct(appointmentId, productId, price, quantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentProductEntity>>> getAppointmentProducts(
      String appointmentId) async {
    try {
      final models = await remoteDataSource.getAppointmentProducts(appointmentId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppointmentTotalPrice(
      String appointmentId, double totalPrice) async {
    try {
      await remoteDataSource.updateAppointmentTotalPrice(appointmentId, totalPrice);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExtraService(String appointmentId, String serviceId) async {
    try {
      await remoteDataSource.deleteExtraService(appointmentId, serviceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExtraProduct(String appointmentId, String productId) async {
    try {
      await remoteDataSource.deleteExtraProduct(appointmentId, productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String id) async {
    try {
      await remoteDataSource.deleteAppointment(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointments(List<String> ids) async {
    try {
      await remoteDataSource.deleteAppointments(ids);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

