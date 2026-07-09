import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

/// Domain entity representing a staff member in CitApps.
class EmployeeEntity extends Equatable {
  final String id;
  final String barbershopId;
  final String? userId; // Link to auth user account if they have access
  final String fullName;
  final String? phone;
  final String? email;
  final UserRole role;
  final double commissionRate;
  final bool isActive;

  const EmployeeEntity({
    required this.id,
    required this.barbershopId,
    this.userId,
    required this.fullName,
    this.phone,
    this.email,
    required this.role,
    this.commissionRate = 0.0,
    this.isActive = true,
  });

  /// Copy helper to mutate entity state.
  EmployeeEntity copyWith({
    String? id,
    String? barbershopId,
    String? userId,
    String? fullName,
    String? phone,
    String? email,
    UserRole? role,
    double? commissionRate,
    bool? isActive,
  }) {
    return EmployeeEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      commissionRate: commissionRate ?? this.commissionRate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        barbershopId,
        userId,
        fullName,
        phone,
        email,
        role,
        commissionRate,
        isActive,
      ];
}
