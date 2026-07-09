import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/services/domain/entities/service_entity.dart';
import 'package:citapps/features/services/domain/repositories/service_repository.dart';
import 'package:citapps/features/services/domain/usecases/get_services_usecase.dart';

class MockServiceRepository extends Mock implements ServiceRepository {}

void main() {
  late GetServicesUseCase useCase;
  late MockServiceRepository mockRepository;

  setUp(() {
    mockRepository = MockServiceRepository();
    useCase = GetServicesUseCase(mockRepository);
  });

  const tBarbershopId = 'shop-123';
  const tServices = [
    ServiceEntity(
      id: 'svc-1',
      barbershopId: tBarbershopId,
      name: 'Corte Degradado',
      price: 15.0,
      durationMinutes: 30,
      isActive: true,
    ),
    ServiceEntity(
      id: 'svc-2',
      barbershopId: tBarbershopId,
      name: 'Corte de Barba',
      price: 10.0,
      durationMinutes: 15,
      isActive: true,
    ),
  ];

  test('should get list of services from repository', () async {
    // Arrange
    when(() => mockRepository.getServices(tBarbershopId))
        .thenAnswer((_) async => const Right(tServices));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Right(tServices));
    verify(() => mockRepository.getServices(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Error de base de datos');
    when(() => mockRepository.getServices(tBarbershopId))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getServices(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
