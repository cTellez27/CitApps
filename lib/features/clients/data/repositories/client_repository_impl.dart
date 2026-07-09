import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/entities/commission_report_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_datasource.dart';
import '../models/client_model.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;

  const ClientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ClientEntity>>> getClients(String barbershopId) async {
    try {
      final models = await remoteDataSource.getClients(barbershopId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> createClient(ClientEntity client) async {
    try {
      final model = ClientModel.fromEntity(client);
      final created = await remoteDataSource.createClient(model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> updateClient(ClientEntity client) async {
    try {
      final model = ClientModel.fromEntity(client);
      final updated = await remoteDataSource.updateClient(model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CommissionReportEntity>> getCommissionsReport({
    required String employeeId,
    required String employeeName,
    required double commissionRate,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final rawList = await remoteDataSource.getCompletedAppointmentsRaw(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
      );

      double totalGenerated = 0.0;
      for (final raw in rawList) {
        totalGenerated += (raw['total_price'] as num? ?? 0.0).toDouble();
      }

      final totalCommission = totalGenerated * (commissionRate / 100.0);

      final report = CommissionReportEntity(
        employeeId: employeeId,
        employeeName: employeeName,
        startDate: startDate,
        endDate: endDate,
        totalGenerated: totalGenerated,
        totalCommission: totalCommission,
        appointmentsCount: rawList.length,
      );

      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
