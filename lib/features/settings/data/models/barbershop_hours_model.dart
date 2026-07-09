import '../../domain/entities/barbershop_hours_entity.dart';

/// Data layer model extending [BarbershopHoursEntity] with JSON serialization.
class BarbershopHoursModel extends BarbershopHoursEntity {
  const BarbershopHoursModel({
    required super.id,
    required super.barbershopId,
    required super.dayOfWeek,
    required super.openTime,
    required super.closeTime,
    required super.isOpen,
  });

  /// Factory constructor to build model from database JSON map.
  factory BarbershopHoursModel.fromJson(Map<String, dynamic> json) {
    return BarbershopHoursModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      openTime: json['open_time'] as String,
      closeTime: json['close_time'] as String,
      isOpen: json['is_open'] as bool? ?? true,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
      'is_open': isOpen,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory BarbershopHoursModel.fromEntity(BarbershopHoursEntity entity) {
    return BarbershopHoursModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      dayOfWeek: entity.dayOfWeek,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      isOpen: entity.isOpen,
    );
  }

  /// Helper to convert model to entity.
  BarbershopHoursEntity toEntity() {
    return BarbershopHoursEntity(
      id: id,
      barbershopId: barbershopId,
      dayOfWeek: dayOfWeek,
      openTime: openTime,
      closeTime: closeTime,
      isOpen: isOpen,
    );
  }
}
