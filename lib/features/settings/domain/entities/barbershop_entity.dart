import 'package:equatable/equatable.dart';

/// Domain entity representing a barbershop configuration in CitApps.
class BarbershopEntity extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? instagram;
  final String currencySymbol;
  final String currencyCode;
  final int appointmentInterval;
  final String timezone;
  final bool isActive;
  final bool enableCommissions;
  final bool enableEmployeeSchedules;

  const BarbershopEntity({
    required this.id,
    required this.name,
    this.logoUrl,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.instagram,
    this.currencySymbol = '\$',
    this.currencyCode = 'MXN',
    this.appointmentInterval = 30,
    this.timezone = 'America/Mexico_City',
    this.isActive = true,
    this.enableCommissions = false,
    this.enableEmployeeSchedules = false,
  });

  /// Copy helper to mutate entity state.
  BarbershopEntity copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? instagram,
    String? currencySymbol,
    String? currencyCode,
    int? appointmentInterval,
    String? timezone,
    bool? isActive,
    bool? enableCommissions,
    bool? enableEmployeeSchedules,
  }) {
    return BarbershopEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      appointmentInterval: appointmentInterval ?? this.appointmentInterval,
      timezone: timezone ?? this.timezone,
      isActive: isActive ?? this.isActive,
      enableCommissions: enableCommissions ?? this.enableCommissions,
      enableEmployeeSchedules: enableEmployeeSchedules ?? this.enableEmployeeSchedules,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logoUrl,
        address,
        phone,
        email,
        website,
        instagram,
        currencySymbol,
        currencyCode,
        appointmentInterval,
        timezone,
        isActive,
        enableCommissions,
        enableEmployeeSchedules,
      ];
}
