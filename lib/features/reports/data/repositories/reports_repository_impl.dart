import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/services_report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  const ReportsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ServicesReportEntity>> getServicesReport({
    required String barbershopId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final report = await remoteDataSource.getServicesReport(
        barbershopId: barbershopId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(report);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
