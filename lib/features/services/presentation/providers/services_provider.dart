import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/usecases/get_services_usecase.dart';
import '../../domain/usecases/create_service_usecase.dart';
import '../../domain/usecases/update_service_usecase.dart';
import '../../domain/usecases/delete_service_usecase.dart';
import '../../domain/usecases/get_service_employees_usecase.dart';
import '../../domain/usecases/update_service_employees_usecase.dart';
import '../../data/datasources/service_remote_datasource.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/repositories/service_repository.dart';

// ── Dependency Injection Providers ──

final serviceRemoteDataSourceProvider = Provider<ServiceRemoteDataSource>((ref) {
  return ServiceRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return ServiceRepositoryImpl(remoteDataSource: ref.watch(serviceRemoteDataSourceProvider));
});

final getServicesUseCaseProvider = Provider<GetServicesUseCase>((ref) {
  return GetServicesUseCase(ref.watch(serviceRepositoryProvider));
});

final createServiceUseCaseProvider = Provider<CreateServiceUseCase>((ref) {
  return CreateServiceUseCase(ref.watch(serviceRepositoryProvider));
});

final updateServiceUseCaseProvider = Provider<UpdateServiceUseCase>((ref) {
  return UpdateServiceUseCase(ref.watch(serviceRepositoryProvider));
});

final deleteServiceUseCaseProvider = Provider<DeleteServiceUseCase>((ref) {
  return DeleteServiceUseCase(ref.watch(serviceRepositoryProvider));
});

final getServiceEmployeesUseCaseProvider = Provider<GetServiceEmployeesUseCase>((ref) {
  return GetServiceEmployeesUseCase(ref.watch(serviceRepositoryProvider));
});

final updateServiceEmployeesUseCaseProvider = Provider<UpdateServiceEmployeesUseCase>((ref) {
  return UpdateServiceEmployeesUseCase(ref.watch(serviceRepositoryProvider));
});

// ── Notifier Providers ──

final servicesStateProvider =
    AsyncNotifierProvider<ServicesNotifier, List<ServiceEntity>>(() {
  return ServicesNotifier();
});

class ServicesNotifier extends AsyncNotifier<List<ServiceEntity>> {
  @override
  Future<List<ServiceEntity>> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    if (barbershopId == null) return [];

    final result = await ref.read(getServicesUseCaseProvider).execute(barbershopId);
    return result.fold(
      (failure) => throw failure,
      (services) => services,
    );
  }

  Future<void> addService(ServiceEntity service) async {
    state = const AsyncValue.loading();
    final result = await ref.read(createServiceUseCaseProvider).execute(service);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(), // Refresh list
    );
  }

  Future<void> updateServiceDetails(ServiceEntity service) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateServiceUseCaseProvider).execute(service);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> deactivateService(String id) async {
    state = const AsyncValue.loading();
    final result = await ref.read(deleteServiceUseCaseProvider).execute(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

// Family provider to load assigned employee IDs for a service
final serviceEmployeesProvider = AsyncNotifierProviderFamily<
    ServiceEmployeesNotifier, List<String>, String>(() {
  return ServiceEmployeesNotifier();
});

class ServiceEmployeesNotifier
    extends FamilyAsyncNotifier<List<String>, String> {
  @override
  Future<List<String>> build(String arg) async {
    final result = await ref.read(getServiceEmployeesUseCaseProvider).execute(arg);
    return result.fold(
      (failure) => throw failure,
      (employeeIds) => employeeIds,
    );
  }

  Future<void> updateAssignments(List<String> employeeIds) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateServiceEmployeesUseCaseProvider).execute(arg, employeeIds);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => state = AsyncValue.data(employeeIds),
    );
  }
}
