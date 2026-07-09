import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';

/// Contract definition for Services repository.
///
/// Handles services catalog and staff associations.
abstract class ServiceRepository {
  /// Fetches services list for a specific barbershop.
  Future<Either<Failure, List<ServiceEntity>>> getServices(String barbershopId);

  /// Registers a new service in the catalog.
  Future<Either<Failure, ServiceEntity>> createService(ServiceEntity service);

  /// Updates details of a catalog service.
  Future<Either<Failure, ServiceEntity>> updateService(ServiceEntity service);

  /// Deactivates (soft deletes) a service from the catalog.
  Future<Either<Failure, void>> deleteService(String id);

  /// Fetches list of Employee IDs assigned to a service.
  Future<Either<Failure, List<String>>> getServiceEmployees(String serviceId);

  /// Updates employee assignments for a service.
  Future<Either<Failure, void>> updateServiceEmployees(
    String serviceId,
    List<String> employeeIds,
  );
}
