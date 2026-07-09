import 'package:equatable/equatable.dart';

/// Domain entity representing operational hours of a barbershop on a specific day of the week.
class BarbershopHoursEntity extends Equatable {
  final String id;
  final String barbershopId;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final String openTime; // Format: "HH:mm:ss" or "HH:mm"
  final String closeTime; // Format: "HH:mm:ss" or "HH:mm"
  final bool isOpen;

  const BarbershopHoursEntity({
    required this.id,
    required this.barbershopId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
  });

  /// Copy helper to mutate entity state.
  BarbershopHoursEntity copyWith({
    String? id,
    String? barbershopId,
    int? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? isOpen,
  }) {
    return BarbershopHoursEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }

  @override
  List<Object?> get props => [id, barbershopId, dayOfWeek, openTime, closeTime, isOpen];
}
