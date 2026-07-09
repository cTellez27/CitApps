import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/entities/employee_schedule_entity.dart';
import '../../domain/usecases/get_employees_usecase.dart';
import '../../domain/usecases/create_employee_usecase.dart';
import '../../domain/usecases/update_employee_usecase.dart';
import '../../domain/usecases/delete_employee_usecase.dart';
import '../../domain/usecases/get_employee_schedule_usecase.dart';
import '../../domain/usecases/update_employee_schedule_usecase.dart';
import '../../data/datasources/employee_remote_datasource.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/repositories/employee_repository.dart';

// ── Dependency Injection Providers ──

final employeeRemoteDataSourceProvider = Provider<EmployeeRemoteDataSource>((ref) {
  return EmployeeRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(remoteDataSource: ref.watch(employeeRemoteDataSourceProvider));
});

final getEmployeesUseCaseProvider = Provider<GetEmployeesUseCase>((ref) {
  return GetEmployeesUseCase(ref.watch(employeeRepositoryProvider));
});

final createEmployeeUseCaseProvider = Provider<CreateEmployeeUseCase>((ref) {
  return CreateEmployeeUseCase(ref.watch(employeeRepositoryProvider));
});

final updateEmployeeUseCaseProvider = Provider<UpdateEmployeeUseCase>((ref) {
  return UpdateEmployeeUseCase(ref.watch(employeeRepositoryProvider));
});

final deleteEmployeeUseCaseProvider = Provider<DeleteEmployeeUseCase>((ref) {
  return DeleteEmployeeUseCase(ref.watch(employeeRepositoryProvider));
});

final getEmployeeScheduleUseCaseProvider = Provider<GetEmployeeScheduleUseCase>((ref) {
  return GetEmployeeScheduleUseCase(ref.watch(employeeRepositoryProvider));
});

final updateEmployeeScheduleUseCaseProvider = Provider<UpdateEmployeeScheduleUseCase>((ref) {
  return UpdateEmployeeScheduleUseCase(ref.watch(employeeRepositoryProvider));
});

// ── Notifier Providers ──

final employeesStateProvider =
    AsyncNotifierProvider<EmployeesNotifier, List<EmployeeEntity>>(() {
  return EmployeesNotifier();
});

class EmployeesNotifier extends AsyncNotifier<List<EmployeeEntity>> {
  @override
  Future<List<EmployeeEntity>> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    if (barbershopId == null) return [];

    final result = await ref.read(getEmployeesUseCaseProvider).execute(barbershopId);
    return result.fold(
      (failure) => throw failure,
      (employees) => employees,
    );
  }

  Future<void> addEmployee(EmployeeEntity employee) async {
    state = const AsyncValue.loading();
    final result = await ref.read(createEmployeeUseCaseProvider).execute(employee);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (created) {
        ref.invalidateSelf(); // Refresh list from server
      },
    );
  }

  Future<void> updateEmployeeDetails(EmployeeEntity employee) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateEmployeeUseCaseProvider).execute(employee);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (updated) {
        ref.invalidateSelf();
      },
    );
  }

  Future<void> deactivateEmployee(String id) async {
    state = const AsyncValue.loading();
    final result = await ref.read(deleteEmployeeUseCaseProvider).execute(id);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) {
        ref.invalidateSelf();
      },
    );
  }
}

// Family provider to load schedule for a specific employee
final employeeScheduleProvider = AsyncNotifierProviderFamily<
    EmployeeScheduleNotifier, List<EmployeeScheduleEntity>, String>(() {
  return EmployeeScheduleNotifier();
});

class EmployeeScheduleNotifier
    extends FamilyAsyncNotifier<List<EmployeeScheduleEntity>, String> {
  @override
  Future<List<EmployeeScheduleEntity>> build(String arg) async {
    final result = await ref.read(getEmployeeScheduleUseCaseProvider).execute(arg);
    return result.fold(
      (failure) => throw failure,
      (schedules) => schedules,
    );
  }

  Future<void> saveSchedule(List<EmployeeScheduleEntity> schedules) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateEmployeeScheduleUseCaseProvider).execute(schedules);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (updatedList) => state = AsyncValue.data(updatedList),
    );
  }
}
