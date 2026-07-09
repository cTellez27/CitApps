import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_entity.dart';
import '../entities/commission_report_entity.dart';

/// Contract definition for Clients and Reports repository.
///
/// Handles client profiles directory and employee payouts analytics.
abstract class ClientRepository {
  /// Fetches clients for a specific barbershop.
  Future<Either<Failure, List<ClientEntity>>> getClients(String barbershopId);

  /// Registers a new customer in the directory.
  Future<Either<Failure, ClientEntity>> createClient(ClientEntity client);

  /// Updates details of a registered customer.
  Future<Either<Failure, ClientEntity>> updateClient(ClientEntity client);

  /// Compiles commission reports for a specific employee and period.
  Future<Either<Failure, CommissionReportEntity>> getCommissionsReport({
    required String employeeId,
    required String employeeName,
    required double commissionRate,
    required DateTime startDate,
    required DateTime endDate,
  });
}
