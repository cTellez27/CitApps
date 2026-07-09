import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/create_barbershop_usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Dependency Injection Providers ──

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remoteDataSource: ref.watch(authRemoteDataSourceProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final createBarbershopUseCaseProvider = Provider<CreateBarbershopUseCase>((ref) {
  return CreateBarbershopUseCase(ref.watch(authRepositoryProvider));
});

// ── Auth State definition ──

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Auth State Notifier ──

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signInUseCase: ref.watch(signInUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    createBarbershopUseCase: ref.watch(createBarbershopUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CreateBarbershopUseCase createBarbershopUseCase;
  final AuthRepository repository;
  StreamSubscription? _authSubscription;

  AuthNotifier({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.createBarbershopUseCase,
    required this.repository,
  }) : super(const AuthInitial()) {
    _init();
  }

  Future<void> _init() async {
    state = const AuthLoading();
    final result = await getCurrentUserUseCase.execute();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) {
        if (user != null) {
          state = Authenticated(user);
        } else {
          state = const Unauthenticated();
        }
      },
    );

    // Listen for real-time auth changes
    _authSubscription = repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthLoading();
    final result = await signInUseCase.execute(email: email, password: password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = Authenticated(user),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AuthLoading();
    final result = await signUpUseCase.execute(
      email: email,
      password: password,
      fullName: fullName,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = Authenticated(user),
    );
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    final result = await signOutUseCase.execute();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const Unauthenticated(),
    );
  }

  Future<void> resetPassword({required String email}) async {
    state = const AuthLoading();
    final result = await resetPasswordUseCase.execute(email: email);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const Unauthenticated(), // Keeps it on login page
    );
  }

  Future<void> createBarbershop({
    required String name,
    required String phone,
    required String address,
  }) async {
    state = const AuthLoading();
    final result = await createBarbershopUseCase.execute(
      name: name,
      phone: phone,
      address: address,
    );
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = Authenticated(user),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
