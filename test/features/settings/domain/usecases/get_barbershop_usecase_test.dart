import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/settings/domain/entities/barbershop_entity.dart';
import 'package:citapps/features/settings/domain/repositories/settings_repository.dart';
import 'package:citapps/features/settings/domain/usecases/get_barbershop_usecase.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late GetBarbershopUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetBarbershopUseCase(mockRepository);
  });

  const tBarbershopId = 'barber-123';
  const tBarbershop = BarbershopEntity(
    id: tBarbershopId,
    name: 'Retro Barber',
    phone: '5551234567',
    address: 'Av Principal 123',
  );

  test('should get barbershop details from repository', () async {
    // Arrange
    when(() => mockRepository.getBarbershop(tBarbershopId))
        .thenAnswer((_) async => const Right(tBarbershop));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Right(tBarbershop));
    verify(() => mockRepository.getBarbershop(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when call fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Error de servidor');
    when(() => mockRepository.getBarbershop(tBarbershopId))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getBarbershop(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
