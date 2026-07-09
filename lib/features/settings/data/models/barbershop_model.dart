import '../../domain/entities/barbershop_entity.dart';

/// Data layer model extending [BarbershopEntity] with JSON serialization.
class BarbershopModel extends BarbershopEntity {
  const BarbershopModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.address,
    super.phone,
    super.email,
    super.website,
    super.instagram,
    super.currencySymbol,
    super.currencyCode,
    super.appointmentInterval,
    super.timezone,
    super.isActive,
  });

  /// Factory constructor to build model from database JSON map.
  factory BarbershopModel.fromJson(Map<String, dynamic> json) {
    return BarbershopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      currencyCode: json['currency_code'] as String? ?? 'MXN',
      appointmentInterval: json['appointment_interval'] as int? ?? 30,
      timezone: json['timezone'] as String? ?? 'America/Mexico_City',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Converts model state back into database JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'instagram': instagram,
      'currency_symbol': currencySymbol,
      'currency_code': currencyCode,
      'appointment_interval': appointmentInterval,
      'timezone': timezone,
      'is_active': isActive,
    };
  }

  /// Factory to convert a base entity into a model instance.
  factory BarbershopModel.fromEntity(BarbershopEntity entity) {
    return BarbershopModel(
      id: entity.id,
      name: entity.name,
      logoUrl: entity.logoUrl,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      website: entity.website,
      instagram: entity.instagram,
      currencySymbol: entity.currencySymbol,
      currencyCode: entity.currencyCode,
      appointmentInterval: entity.appointmentInterval,
      timezone: entity.timezone,
      isActive: entity.isActive,
    );
  }

  /// Helper to convert model to entity.
  BarbershopEntity toEntity() {
    return BarbershopEntity(
      id: id,
      name: name,
      logoUrl: logoUrl,
      address: address,
      phone: phone,
      email: email,
      website: website,
      instagram: instagram,
      currencySymbol: currencySymbol,
      currencyCode: currencyCode,
      appointmentInterval: appointmentInterval,
      timezone: timezone,
      isActive: isActive,
    );
  }
}
