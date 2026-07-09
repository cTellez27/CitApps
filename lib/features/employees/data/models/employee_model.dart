import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/employee_entity.dart';

/// Data layer model extending [EmployeeEntity] with JSON serialization.
class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.barbershopId,
    super.userId,
    required super.fullName,
    super.phone,
    super.email,
    required super.role,
    super.commissionRate,
    super.isActive,
  });

  /// Factory constructor to build model from database JSON map.
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String,
      userId: json['user_id'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'barber'),
      commissionRate: (json['commission_rate'] as num? ?? 0.0).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role.name,
      'commission_rate': commissionRate,
      'is_active': isActive,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      userId: entity.userId,
      fullName: entity.fullName,
      phone: entity.phone,
      email: entity.email,
      role: entity.role,
      commissionRate: entity.commissionRate,
      isActive: entity.isActive,
    );
  }

  /// Helper to convert model to entity.
  EmployeeEntity toEntity() {
    return EmployeeEntity(
      id: id,
      barbershopId: barbershopId,
      userId: userId,
      fullName: fullName,
      phone: phone,
      email: email,
      role: role,
      commissionRate: commissionRate,
      isActive: isActive,
    );
  }
}
