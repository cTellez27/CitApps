import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

class UpdateClientUseCase {
  final ClientRepository repository;

  const UpdateClientUseCase(this.repository);

  Future<Either<Failure, ClientEntity>> execute(ClientEntity client) {
    return repository.updateClient(client);
  }
}
