import '../../domain/entities/employee_schedule_entity.dart';

/// Data layer model extending [EmployeeScheduleEntity] with JSON serialization.
class EmployeeScheduleModel extends EmployeeScheduleEntity {
  const EmployeeScheduleModel({
    required super.id,
    required super.employeeId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.isWorking,
  });

  /// Factory constructor to build model from database JSON map.
  factory EmployeeScheduleModel.fromJson(Map<String, dynamic> json) {
    return EmployeeScheduleModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isWorking: json['is_working'] as bool? ?? true,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_working': isWorking,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory EmployeeScheduleModel.fromEntity(EmployeeScheduleEntity entity) {
    return EmployeeScheduleModel(
      id: entity.id,
      employeeId: entity.employeeId,
      dayOfWeek: entity.dayOfWeek,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isWorking: entity.isWorking,
    );
  }

  /// Helper to convert model to entity.
  EmployeeScheduleEntity toEntity() {
    return EmployeeScheduleEntity(
      id: id,
      employeeId: employeeId,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      isWorking: isWorking,
    );
  }
}
