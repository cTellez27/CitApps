import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

class GetClientsUseCase {
  final ClientRepository repository;

  const GetClientsUseCase(this.repository);

  Future<Either<Failure, List<ClientEntity>>> execute(String barbershopId) {
    return repository.getClients(barbershopId);
  }
}
