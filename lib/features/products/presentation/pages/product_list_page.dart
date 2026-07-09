import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/products_provider.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario de Productos'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'Inventario vacío',
              subtitle: 'Agrega productos a tu inventario tocando el botón "+".',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.md),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isLowStock = product.stock <= 3;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppSizes.md),
                  leading: CircleAvatar(
                    backgroundColor: isLowStock
                        ? AppColors.error.withAlpha(20)
                        : AppColors.primary.withAlpha(20),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: isLowStock ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  title: Text(product.name, style: AppTextStyles.h4),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (product.description != null &&
                          product.description!.isNotEmpty) ...[
                        Text(
                          product.description!,
                          style: AppTextStyles.bodySm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isLowStock
                                  ? AppColors.error.withAlpha(30)
                                  : AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isLowStock
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          if (!product.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Inactivo',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    CurrencyUtils.format(product.price),
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () => context.push('/inventory/${product.id}/edit'),
                ),
              );
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(productsStateProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/inventory/new'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
