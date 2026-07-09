import 'package:equatable/equatable.dart';

/// Domain entity representing a staff member's working schedule on a specific day of the week.
class EmployeeScheduleEntity extends Equatable {
  final String id;
  final String employeeId;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final String startTime; // Format: "HH:mm:ss" or "HH:mm"
  final String endTime; // Format: "HH:mm:ss" or "HH:mm"
  final bool isWorking;

  const EmployeeScheduleEntity({
    required this.id,
    required this.employeeId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorking,
  });

  /// Copy helper to mutate entity state.
  EmployeeScheduleEntity copyWith({
    String? id,
    String? employeeId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isWorking,
  }) {
    return EmployeeScheduleEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWorking: isWorking ?? this.isWorking,
    );
  }

  @override
  List<Object?> get props => [id, employeeId, dayOfWeek, startTime, endTime, isWorking];
}
