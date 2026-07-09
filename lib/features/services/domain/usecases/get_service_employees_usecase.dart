import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/service_repository.dart';

class GetServiceEmployeesUseCase {
  final ServiceRepository repository;

  const GetServiceEmployeesUseCase(this.repository);

  Future<Either<Failure, List<String>>> execute(String serviceId) {
    return repository.getServiceEmployees(serviceId);
  }
}
