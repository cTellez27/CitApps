import '../../domain/entities/appointment_entity.dart';

/// Data layer model extending [AppointmentEntity] with JSON serialization.
class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.barbershopId,
    required super.employeeId,
    super.clientId,
    required super.customerName,
    super.customerPhone,
    super.customerEmail,
    required super.startTime,
    required super.endTime,
    super.status,
    required super.totalPrice,
    super.notes,
  });

  /// Factory constructor to build model from database JSON map.
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String,
      employeeId: json['employee_id'] as String,
      clientId: json['client_id'] as String?,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      customerEmail: json['customer_email'] as String?,
      startTime: DateTime.parse(json['start_time'] as String).toLocal(),
      endTime: DateTime.parse(json['end_time'] as String).toLocal(),
      status: json['status'] as String? ?? 'pending',
      totalPrice: (json['total_price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'employee_id': employeeId,
      'client_id': clientId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
      'status': status,
      'total_price': totalPrice,
      'notes': notes,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      employeeId: entity.employeeId,
      clientId: entity.clientId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      customerEmail: entity.customerEmail,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      totalPrice: entity.totalPrice,
      notes: entity.notes,
    );
  }

  /// Helper to convert model to entity.
  AppointmentEntity toEntity() {
    return AppointmentEntity(
      id: id,
      barbershopId: barbershopId,
      employeeId: employeeId,
      clientId: clientId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      startTime: startTime,
      endTime: endTime,
      status: status,
      totalPrice: totalPrice,
      notes: notes,
    );
  }
}
