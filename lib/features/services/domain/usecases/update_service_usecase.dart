import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';
import '../repositories/service_repository.dart';

class UpdateServiceUseCase {
  final ServiceRepository repository;

  const UpdateServiceUseCase(this.repository);

  Future<Either<Failure, ServiceEntity>> execute(ServiceEntity service) {
    return repository.updateService(service);
  }
}
