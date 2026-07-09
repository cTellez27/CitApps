import 'package:equatable/equatable.dart';

/// User roles supported in CitApps.
enum UserRole {
  owner,
  admin,
  barber,
  receptionist;

  /// Returns enum from string name.
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => UserRole.barber,
    );
  }
}

/// Domain entity representing a user profile in CitApps.
class UserEntity extends Equatable {
  final String id;
  final String? barbershopId;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final bool isActive;
  final String? email;

  const UserEntity({
    required this.id,
    this.barbershopId,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.email,
  });

  /// Copy helper to mutate entity state.
  UserEntity copyWith({
    String? id,
    String? barbershopId,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    bool? isActive,
    String? email,
  }) {
    return UserEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id, barbershopId, fullName, avatarUrl, role, isActive, email];
}
