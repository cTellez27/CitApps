import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.barbershopId,
    required super.name,
    super.description,
    required super.price,
    required super.stock,
    super.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      barbershopId: json['barbershop_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barbershop_id': barbershopId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'is_active': isActive,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      barbershopId: entity.barbershopId,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      stock: entity.stock,
      isActive: entity.isActive,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      barbershopId: barbershopId,
      name: name,
      description: description,
      price: price,
      stock: stock,
      isActive: isActive,
    );
  }
}
