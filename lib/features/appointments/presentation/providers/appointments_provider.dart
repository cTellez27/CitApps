import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../settings/domain/entities/barbershop_hours_entity.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../employees/domain/entities/employee_schedule_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_service_entity.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/create_appointment_usecase.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';
import '../../domain/usecases/get_employee_appointments_usecase.dart';
import '../../domain/usecases/get_appointment_services_usecase.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';

// ── Dependency Injection Providers ──

final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDataSource>((ref) {
  return AppointmentRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    remoteDataSource: ref.watch(appointmentRemoteDataSourceProvider),
  );
});

final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>((ref) {
  return GetAppointmentsUseCase(ref.watch(appointmentRepositoryProvider));
});

final createAppointmentUseCaseProvider = Provider<CreateAppointmentUseCase>((ref) {
  return CreateAppointmentUseCase(ref.watch(appointmentRepositoryProvider));
});

final cancelAppointmentUseCaseProvider = Provider<CancelAppointmentUseCase>((ref) {
  return CancelAppointmentUseCase(ref.watch(appointmentRepositoryProvider));
});

final getEmployeeAppointmentsUseCaseProvider = Provider<GetEmployeeAppointmentsUseCase>((ref) {
  return GetEmployeeAppointmentsUseCase(ref.watch(appointmentRepositoryProvider));
});

final getAppointmentServicesUseCaseProvider = Provider<GetAppointmentServicesUseCase>((ref) {
  return GetAppointmentServicesUseCase(ref.watch(appointmentRepositoryProvider));
});

// ── Notifier / State Providers ──

/// Date selected on the agenda calendar view.
final activeDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// List of appointments for the current barbershop on the active date.
final appointmentsStateProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<AppointmentEntity>>(() {
  return AppointmentsNotifier();
});

class AppointmentsNotifier extends AsyncNotifier<List<AppointmentEntity>> {
  @override
  Future<List<AppointmentEntity>> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    final activeDate = ref.watch(activeDateProvider);
    if (barbershopId == null) return [];

    final result = await ref.read(getAppointmentsUseCaseProvider).execute(barbershopId, activeDate);
    return result.fold(
      (failure) => throw failure,
      (appointments) => appointments,
    );
  }

  Future<void> bookAppointment({
    required AppointmentEntity appointment,
    required List<AppointmentServiceEntity> services,
  }) async {
    state = const AsyncValue.loading();
    final result = await ref.read(createAppointmentUseCaseProvider).execute(
          appointment: appointment,
          services: services,
        );
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(), // Refresh list
    );
  }

  Future<void> cancelBooking(String appointmentId) async {
    state = const AsyncValue.loading();
    final result = await ref.read(cancelAppointmentUseCaseProvider).execute(appointmentId);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

// ── Availability / Slots Calculation Providers ──

class EmployeeAvailabilityQuery {
  final String employeeId;
  final DateTime date;

  const EmployeeAvailabilityQuery({required this.employeeId, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAvailabilityQuery &&
          runtimeType == other.runtimeType &&
          employeeId == other.employeeId &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day;

  @override
  int get hashCode => employeeId.hashCode ^ date.year.hashCode ^ date.month.hashCode ^ date.day.hashCode;
}

/// Dynamic provider to get 30-min free slots for an employee on a given day.
final employeeAvailabilityProvider =
    FutureProvider.family<List<DateTime>, EmployeeAvailabilityQuery>((ref, query) async {
  final barbershopAsync = ref.watch(barbershopStateProvider);
  final hoursAsync = ref.watch(barbershopHoursStateProvider);

  final barbershop = barbershopAsync.valueOrNull;
  final globalHours = hoursAsync.valueOrNull ?? [];

  if (barbershop == null) return [];

  // 1. Determine working hours for this employee on this day of week
  // Sunday = 0, Monday = 1, ..., Saturday = 6 (Note: DateTime.weekday: Monday=1, Sunday=7)
  final weekday = query.date.weekday == 7 ? 0 : query.date.weekday;
  
  String dayOpenStr = '09:00:00';
  String dayCloseStr = '18:00:00';

  if (barbershop.enableEmployeeSchedules) {
    // Load employee schedule
    final scheduleAsync = await ref.watch(employeeScheduleProvider(query.employeeId).future);
    final customDay = scheduleAsync.firstWhere(
      (s) => s.dayOfWeek == weekday,
      orElse: () => EmployeeScheduleEntity(
        id: '',
        employeeId: query.employeeId,
        dayOfWeek: weekday,
        startTime: '09:00:00',
        endTime: '18:00:00',
        isWorking: weekday != 0,
      ),
    );

    if (!customDay.isWorking) return [];
    dayOpenStr = customDay.startTime;
    dayCloseStr = customDay.endTime;
  } else {
    // Fallback to global barbershop hours
    final globalDay = globalHours.firstWhere(
      (h) => h.dayOfWeek == weekday,
      orElse: () => BarbershopHoursEntity(
        id: '',
        barbershopId: barbershop.id,
        dayOfWeek: weekday,
        openTime: '09:00:00',
        closeTime: '18:00:00',
        isOpen: weekday != 0,
      ),
    );

    if (!globalDay.isOpen) return [];
    dayOpenStr = globalDay.openTime;
    dayCloseStr = globalDay.closeTime;
  }

  // Parse start/end times
  final openParts = dayOpenStr.split(':');
  final closeParts = dayCloseStr.split(':');
  
  final startWorking = DateTime(
    query.date.year,
    query.date.month,
    query.date.day,
    int.parse(openParts[0]),
    int.parse(openParts[1]),
  );

  final endWorking = DateTime(
    query.date.year,
    query.date.month,
    query.date.day,
    int.parse(closeParts[0]),
    int.parse(closeParts[1]),
  );

  // 2. Fetch all appointments of this employee for this day
  final appointmentsResult = await ref
      .read(getEmployeeAppointmentsUseCaseProvider)
      .execute(query.employeeId, query.date);
  
  final List<AppointmentEntity> employeeAppointments = appointmentsResult.fold(
    (_) => [],
    (list) => list,
  );

  // 3. Generate 30-minute intervals
  final List<DateTime> allSlots = [];
  DateTime current = startWorking;
  final interval = Duration(minutes: barbershop.appointmentInterval);

  while (current.isBefore(endWorking)) {
    // Only show slots that are not in the past if query date is today
    final now = DateTime.now();
    if (current.isAfter(now) || (query.date.year != now.year || query.date.month != now.month || query.date.day != now.day)) {
      allSlots.add(current);
    }
    current = current.add(interval);
  }

  // 4. Filter slots that overlap with any existing appointment
  final List<DateTime> availableSlots = [];
  for (final slot in allSlots) {
    bool hasOverlap = false;
    for (final appt in employeeAppointments) {
      // Overlaps if slot falls inside [appt.startTime, appt.endTime)
      if ((slot.isAtSameMomentAs(appt.startTime) || slot.isAfter(appt.startTime)) &&
          slot.isBefore(appt.endTime)) {
        hasOverlap = true;
        break;
      }
    }
    if (!hasOverlap) {
      availableSlots.add(slot);
    }
  }

  return availableSlots;
});
