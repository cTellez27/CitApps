import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/auth/domain/entities/user_entity.dart';
import 'package:citapps/features/auth/domain/repositories/auth_repository.dart';
import 'package:citapps/features/auth/domain/usecases/sign_in_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  const tEmail = 'test@barber.com';
  const tPassword = 'Password123';
  const tUser = UserEntity(
    id: '123',
    fullName: 'Test User',
    role: UserRole.owner,
    isActive: true,
  );

  test('should sign in user via AuthRepository', () async {
    // Arrange
    when(() => mockRepository.signIn(email: tEmail, password: tPassword))
        .thenAnswer((_) async => const Right(tUser));

    // Act
    final result = await useCase.execute(email: tEmail, password: tPassword);

    // Assert
    expect(result, const Right(tUser));
    verify(() => mockRepository.signIn(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AuthFailure when sign in fails', () async {
    // Arrange
    const tFailure = AuthFailure(message: 'Invalid credentials');
    when(() => mockRepository.signIn(email: tEmail, password: tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(email: tEmail, password: tPassword);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.signIn(email: tEmail, password: tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
