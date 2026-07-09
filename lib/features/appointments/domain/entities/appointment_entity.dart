import 'package:equatable/equatable.dart';

/// Domain entity representing a customer appointment booking.
class AppointmentEntity extends Equatable {
  final String id;
  final String barbershopId;
  final String employeeId;
  final String? clientId; // Registered client profile if any
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final double totalPrice;
  final String? notes;

  const AppointmentEntity({
    required this.id,
    required this.barbershopId,
    required this.employeeId,
    this.clientId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.startTime,
    required this.endTime,
    this.status = 'pending',
    required this.totalPrice,
    this.notes,
  });

  /// Copy helper to mutate entity state.
  AppointmentEntity copyWith({
    String? id,
    String? barbershopId,
    String? employeeId,
    String? clientId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    double? totalPrice,
    String? notes,
  }) {
    return AppointmentEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      employeeId: employeeId ?? this.employeeId,
      clientId: clientId ?? this.clientId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        barbershopId,
        employeeId,
        clientId,
        customerName,
        customerPhone,
        customerEmail,
        startTime,
        endTime,
        status,
        totalPrice,
        notes,
      ];
}
