import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(String barbershopId);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final sb.SupabaseClient supabase;

  ProductRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<ProductModel>> getProducts(String barbershopId) async {
    try {
      final List<dynamic> data = await supabase
          .from('products')
          .select()
          .eq('barbershop_id', barbershopId)
          .order('name', ascending: true);

      return data.map((item) => ProductModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener productos: $e');
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final data = await supabase
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return ProductModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al registrar el producto: $e');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final data = await supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return ProductModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el producto: $e');
    }
  }
}
