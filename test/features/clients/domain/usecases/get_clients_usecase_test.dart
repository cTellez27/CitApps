import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/clients/domain/entities/client_entity.dart';
import 'package:citapps/features/clients/domain/repositories/client_repository.dart';
import 'package:citapps/features/clients/domain/usecases/get_clients_usecase.dart';

class MockClientRepository extends Mock implements ClientRepository {}

void main() {
  late GetClientsUseCase useCase;
  late MockClientRepository mockRepository;

  setUp(() {
    mockRepository = MockClientRepository();
    useCase = GetClientsUseCase(mockRepository);
  });

  const tBarbershopId = 'shop-123';
  const tClients = [
    ClientEntity(
      id: 'client-1',
      barbershopId: tBarbershopId,
      fullName: 'Carlos Slim',
      phone: '5551234',
      email: 'carlos@slim.com',
    ),
    ClientEntity(
      id: 'client-2',
      barbershopId: tBarbershopId,
      fullName: 'Maria Felix',
      phone: '5559876',
      email: 'maria@felix.com',
    ),
  ];

  test('should get list of clients from repository', () async {
    // Arrange
    when(() => mockRepository.getClients(tBarbershopId))
        .thenAnswer((_) async => const Right(tClients));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Right(tClients));
    verify(() => mockRepository.getClients(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Error de base de datos');
    when(() => mockRepository.getClients(tBarbershopId))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getClients(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
