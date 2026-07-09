import 'package:equatable/equatable.dart';

/// Domain entity representing a barbershop service (cut, shave, dye, etc.).
class ServiceEntity extends Equatable {
  final String id;
  final String barbershopId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final bool isActive;

  const ServiceEntity({
    required this.id,
    required this.barbershopId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.isActive = true,
  });

  /// Copy helper to mutate entity state.
  ServiceEntity copyWith({
    String? id,
    String? barbershopId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    bool? isActive,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, barbershopId, name, description, price, durationMinutes, isActive];
}
