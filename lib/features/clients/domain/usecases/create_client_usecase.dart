import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

class CreateClientUseCase {
  final ClientRepository repository;

  const CreateClientUseCase(this.repository);

  Future<Either<Failure, ClientEntity>> execute(ClientEntity client) {
    return repository.createClient(client);
  }
}
