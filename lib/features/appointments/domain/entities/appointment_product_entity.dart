import 'package:equatable/equatable.dart';

class AppointmentProductEntity extends Equatable {
  final String appointmentId;
  final String productId;
  final int quantity;
  final double price;

  const AppointmentProductEntity({
    required this.appointmentId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [appointmentId, productId, quantity, price];
}
