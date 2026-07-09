import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/appointments/domain/entities/appointment_entity.dart';
import 'package:citapps/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:citapps/features/appointments/domain/usecases/get_appointments_usecase.dart';

class MockAppointmentRepository extends Mock implements AppointmentRepository {}

void main() {
  late GetAppointmentsUseCase useCase;
  late MockAppointmentRepository mockRepository;

  setUp(() {
    mockRepository = MockAppointmentRepository();
    useCase = GetAppointmentsUseCase(mockRepository);
  });

  const tBarbershopId = 'shop-123';
  final tDate = DateTime(2026, 7, 9);
  final tAppointments = [
    AppointmentEntity(
      id: 'appt-1',
      barbershopId: tBarbershopId,
      employeeId: 'emp-1',
      customerName: 'Juan Perez',
      startTime: DateTime(2026, 7, 9, 10, 0),
      endTime: DateTime(2026, 7, 9, 10, 30),
      totalPrice: 15.0,
      status: 'pending',
    ),
    AppointmentEntity(
      id: 'appt-2',
      barbershopId: tBarbershopId,
      employeeId: 'emp-2',
      customerName: 'Ana Gomez',
      startTime: DateTime(2026, 7, 9, 11, 0),
      endTime: DateTime(2026, 7, 9, 11, 45),
      totalPrice: 25.0,
      status: 'confirmed',
    ),
  ];

  test('should get list of appointments from repository', () async {
    // Arrange
    when(() => mockRepository.getAppointments(tBarbershopId, tDate))
        .thenAnswer((_) async => Right(tAppointments));

    // Act
    final result = await useCase.execute(tBarbershopId, tDate);

    // Assert
    expect(result, Right(tAppointments));
    verify(() => mockRepository.getAppointments(tBarbershopId, tDate)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when repository call fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Error de base de datos');
    when(() => mockRepository.getAppointments(tBarbershopId, tDate))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(tBarbershopId, tDate);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.getAppointments(tBarbershopId, tDate)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
