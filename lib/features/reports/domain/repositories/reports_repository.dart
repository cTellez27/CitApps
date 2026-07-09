import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/services_report_entity.dart';

/// Contract for the Reports repository.
abstract class ReportsRepository {
  /// Fetches services report for the given barbershop and date range.
  Future<Either<Failure, ServicesReportEntity>> getServicesReport({
    required String barbershopId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
