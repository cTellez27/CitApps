import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/service_repository.dart';

class DeleteServiceUseCase {
  final ServiceRepository repository;

  const DeleteServiceUseCase(this.repository);

  Future<Either<Failure, void>> execute(String id) {
    return repository.deleteService(id);
  }
}
