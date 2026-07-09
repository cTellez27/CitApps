import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

// ── DI Providers ──

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(remoteDataSource: ref.watch(productRemoteDataSourceProvider));
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  return CreateProductUseCase(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.watch(productRepositoryProvider));
});

// ── Notifier Provider ──

final productsStateProvider =
    AsyncNotifierProvider<ProductsNotifier, List<ProductEntity>>(() {
  return ProductsNotifier();
});

class ProductsNotifier extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    if (barbershopId == null) return [];

    final result = await ref.read(getProductsUseCaseProvider).execute(barbershopId);
    return result.fold(
      (failure) => throw failure,
      (products) => products,
    );
  }

  Future<void> addProduct(ProductEntity product) async {
    state = const AsyncValue.loading();
    final result = await ref.read(createProductUseCaseProvider).execute(product);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> updateProductDetails(ProductEntity product) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateProductUseCaseProvider).execute(product);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}
