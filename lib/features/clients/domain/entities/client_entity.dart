import 'package:equatable/equatable.dart';

/// Domain entity representing a customer registered in the barbershop database.
class ClientEntity extends Equatable {
  final String id;
  final String barbershopId;
  final String fullName;
  final String? phone;
  final String? email;
  final String? notes;

  const ClientEntity({
    required this.id,
    required this.barbershopId,
    required this.fullName,
    this.phone,
    this.email,
    this.notes,
  });

  /// Copy helper to mutate entity state.
  ClientEntity copyWith({
    String? id,
    String? barbershopId,
    String? fullName,
    String? phone,
    String? email,
    String? notes,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, barbershopId, fullName, phone, email, notes];
}
