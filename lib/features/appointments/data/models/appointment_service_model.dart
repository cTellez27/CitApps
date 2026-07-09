import '../../domain/entities/appointment_service_entity.dart';

/// Data layer model extending [AppointmentServiceEntity] with JSON serialization.
class AppointmentServiceModel extends AppointmentServiceEntity {
  const AppointmentServiceModel({
    required super.appointmentId,
    required super.serviceId,
    required super.price,
  });

  /// Factory constructor to build model from database JSON map.
  factory AppointmentServiceModel.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceModel(
      appointmentId: json['appointment_id'] as String,
      serviceId: json['service_id'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'service_id': serviceId,
      'price': price,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory AppointmentServiceModel.fromEntity(AppointmentServiceEntity entity) {
    return AppointmentServiceModel(
      appointmentId: entity.appointmentId,
      serviceId: entity.serviceId,
      price: entity.price,
    );
  }

  /// Helper to convert model to entity.
  AppointmentServiceEntity toEntity() {
    return AppointmentServiceEntity(
      appointmentId: appointmentId,
      serviceId: serviceId,
      price: price,
    );
  }
}
