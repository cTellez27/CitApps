import 'package:equatable/equatable.dart';

/// Domain entity representing a service performed during an appointment with locked price.
class AppointmentServiceEntity extends Equatable {
  final String appointmentId;
  final String serviceId;
  final double price;

  const AppointmentServiceEntity({
    required this.appointmentId,
    required this.serviceId,
    required this.price,
  });

  @override
  List<Object?> get props => [appointmentId, serviceId, price];
}
