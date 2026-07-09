import '../../domain/entities/appointment_product_entity.dart';

class AppointmentProductModel extends AppointmentProductEntity {
  const AppointmentProductModel({
    required super.appointmentId,
    required super.productId,
    required super.quantity,
    required super.price,
  });

  factory AppointmentProductModel.fromJson(Map<String, dynamic> json) {
    return AppointmentProductModel(
      appointmentId: json['appointment_id'] as String,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory AppointmentProductModel.fromEntity(AppointmentProductEntity entity) {
    return AppointmentProductModel(
      appointmentId: entity.appointmentId,
      productId: entity.productId,
      quantity: entity.quantity,
      price: entity.price,
    );
  }

  AppointmentProductEntity toEntity() {
    return AppointmentProductEntity(
      appointmentId: appointmentId,
      productId: productId,
      quantity: quantity,
      price: price,
    );
  }
}
