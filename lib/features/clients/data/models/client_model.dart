import '../../domain/entities/client_entity.dart';

/// Data layer model extending [ClientEntity] with JSON serialization.
class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.barbershopId,
    required super.fullName,
    super.phone,
    super.email,
    super.notes,
  });

  /// Factory constructor to build model from database JSON map.
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'notes': notes,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory ClientModel.fromEntity(ClientEntity entity) {
    return ClientModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      fullName: entity.fullName,
      phone: entity.phone,
      email: entity.email,
      notes: entity.notes,
    );
  }

  /// Helper to convert model to entity.
  ClientEntity toEntity() {
    return ClientEntity(
      id: id,
      barbershopId: barbershopId,
      fullName: fullName,
      phone: phone,
      email: email,
      notes: notes,
    );
  }
}
