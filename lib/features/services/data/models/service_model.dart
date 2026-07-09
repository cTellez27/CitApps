import '../../domain/entities/service_entity.dart';

/// Data layer model extending [ServiceEntity] with JSON serialization.
class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.barbershopId,
    required super.name,
    super.description,
    required super.price,
    required super.durationMinutes,
    super.isActive,
  });

  /// Factory constructor to build model from database JSON map.
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'is_active': isActive,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory ServiceModel.fromEntity(ServiceEntity entity) {
    return ServiceModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      durationMinutes: entity.durationMinutes,
      isActive: entity.isActive,
    );
  }

  /// Helper to convert model to entity.
  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      barbershopId: barbershopId,
      name: name,
      description: description,
      price: price,
      durationMinutes: durationMinutes,
      isActive: isActive,
    );
  }
}
