import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

class GetServicesUseCase {
  final ServiceRepository repository;

  const GetServicesUseCase(this.repository);

  Future<Either<Failure, List<ServiceEntity>>> execute(String barbershopId) {
    return repository.getServices(barbershopId);
  }
}
