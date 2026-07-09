import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/auth/domain/entities/user_entity.dart';
import 'package:citapps/features/employees/domain/entities/employee_entity.dart';
import 'package:citapps/features/employees/domain/repositories/employee_repository.dart';
import 'package:citapps/features/employees/domain/usecases/get_employees_usecase.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  late GetEmployeesUseCase useCase;
  late MockEmployeeRepository mockRepository;

  setUp(() {
    mockRepository = MockEmployeeRepository();
    useCase = GetEmployeesUseCase(mockRepository);
  });

  const tBarbershopId = 'shop-123';
  const tEmployees = [
    EmployeeEntity(
      id: 'emp-1',
      barbershopId: tBarbershopId,
      fullName: 'Juan Perez',
      role: UserRole.barber,
      commissionRate: 10.0,
      isActive: true,
    ),
    EmployeeEntity(
      id: 'emp-2',
      barbershopId: tBarbershopId,
      fullName: 'Ana Gomez',
      role: UserRole.receptionist,
      commissionRate: 0.0,
      isActive: true,
    ),
  ];

  test('should get list of employees from repository', () async {
    // Arrange
    when(() => mockRepository.getEmployees(tBarbershopId))
        .thenAnswer((_) async => const Right(tEmployees));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Right(tEmployees));
    verify(() => mockRepository.getEmployees(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Error de base de datos');
    when(() => mockRepository.getEmployees(tBarbershopId))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(tBarbershopId);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getEmployees(tBarbershopId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
