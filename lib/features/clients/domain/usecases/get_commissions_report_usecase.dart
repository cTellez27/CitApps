import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/commission_report_entity.dart';
import '../repositories/client_repository.dart';

class GetCommissionsReportUseCase {
  final ClientRepository repository;

  const GetCommissionsReportUseCase(this.repository);

  Future<Either<Failure, CommissionReportEntity>> execute({
    required String employeeId,
    required String employeeName,
    required double commissionRate,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getCommissionsReport(
      employeeId: employeeId,
      employeeName: employeeName,
      commissionRate: commissionRate,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
