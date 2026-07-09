import '../../domain/entities/user_entity.dart';

/// Data layer model extending [UserEntity] with JSON serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.barbershopId,
    required super.fullName,
    super.avatarUrl,
    required super.role,
    super.isActive = true,
    super.email,
  });

  /// Factory constructor to build model from database JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json, {String? email}) {
    return UserModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'barber'),
      isActive: json['is_active'] as bool? ?? true,
      email: email,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.name,
      'is_active': isActive,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      fullName: entity.fullName,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      isActive: entity.isActive,
      email: entity.email,
    );
  }

  /// Helper to convert model to entity.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      barbershopId: barbershopId,
      fullName: fullName,
      avatarUrl: avatarUrl,
      role: role,
      isActive: isActive,
      email: email,
    );
  }
}
