import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/barbershop_entity.dart';
import '../../domain/entities/barbershop_hours_entity.dart';
import '../../domain/usecases/get_barbershop_usecase.dart';
import '../../domain/usecases/get_barbershop_hours_usecase.dart';
import '../../domain/usecases/update_barbershop_usecase.dart';
import '../../domain/usecases/update_barbershop_hours_usecase.dart';
import '../../data/datasources/settings_remote_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';

// ── Dependency Injection Providers ──

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(remoteDataSource: ref.watch(settingsRemoteDataSourceProvider));
});

final getBarbershopUseCaseProvider = Provider<GetBarbershopUseCase>((ref) {
  return GetBarbershopUseCase(ref.watch(settingsRepositoryProvider));
});

final updateBarbershopUseCaseProvider = Provider<UpdateBarbershopUseCase>((ref) {
  return UpdateBarbershopUseCase(ref.watch(settingsRepositoryProvider));
});

final getBarbershopHoursUseCaseProvider = Provider<GetBarbershopHoursUseCase>((ref) {
  return GetBarbershopHoursUseCase(ref.watch(settingsRepositoryProvider));
});

final updateBarbershopHoursUseCaseProvider = Provider<UpdateBarbershopHoursUseCase>((ref) {
  return UpdateBarbershopHoursUseCase(ref.watch(settingsRepositoryProvider));
});

// Helper provider to extract active Barbershop ID
final activeBarbershopIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState is Authenticated) {
    return authState.user.barbershopId;
  }
  return null;
});

// ── Notifier Providers ──

final barbershopStateProvider =
    AsyncNotifierProvider<BarbershopNotifier, BarbershopEntity?>(() {
  return BarbershopNotifier();
});

class BarbershopNotifier extends AsyncNotifier<BarbershopEntity?> {
  @override
  Future<BarbershopEntity?> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    if (barbershopId == null) return null;

    final result = await ref.read(getBarbershopUseCaseProvider).execute(barbershopId);
    return result.fold(
      (failure) => throw failure,
      (barbershop) => barbershop,
    );
  }

  Future<void> updateBarbershop(BarbershopEntity updated) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateBarbershopUseCaseProvider).execute(updated);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (barbershop) => state = AsyncValue.data(barbershop),
    );
  }
}

final barbershopHoursStateProvider =
    AsyncNotifierProvider<BarbershopHoursNotifier, List<BarbershopHoursEntity>>(() {
  return BarbershopHoursNotifier();
});

class BarbershopHoursNotifier extends AsyncNotifier<List<BarbershopHoursEntity>> {
  @override
  Future<List<BarbershopHoursEntity>> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    if (barbershopId == null) return [];

    final result = await ref.read(getBarbershopHoursUseCaseProvider).execute(barbershopId);
    return result.fold(
      (failure) => throw failure,
      (hours) => hours,
    );
  }

  Future<void> updateHours(List<BarbershopHoursEntity> updatedList) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateBarbershopHoursUseCaseProvider).execute(updatedList);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (hours) => state = AsyncValue.data(hours),
    );
  }
}
