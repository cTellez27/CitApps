import 'package:equatable/equatable.dart';

/// Domain entity representing a product in the barbershop's inventory.
class ProductEntity extends Equatable {
  final String id;
  final String barbershopId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.barbershopId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.isActive = true,
  });

  ProductEntity copyWith({
    String? id,
    String? barbershopId,
    String? name,
    String? description,
    double? price,
    int? stock,
    bool? isActive,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      barbershopId: barbershopId ?? this.barbershopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, barbershopId, name, description, price, stock, isActive];
}
