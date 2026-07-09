import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

class CreateServiceUseCase {
  final ServiceRepository repository;

  const CreateServiceUseCase(this.repository);

  Future<Either<Failure, ServiceEntity>> execute(ServiceEntity service) {
    return repository.createService(service);
  }
}
