import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/services_report_entity.dart';
import '../repositories/reports_repository.dart';

/// Use case: generate a services report for a barbershop within a date range.
class GetServicesReportUseCase {
  final ReportsRepository _repository;

  const GetServicesReportUseCase(this._repository);

  Future<Either<Failure, ServicesReportEntity>> execute({
    required String barbershopId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getServicesReport(
      barbershopId: barbershopId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
