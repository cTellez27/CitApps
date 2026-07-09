import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/products_provider.dart';
import '../../domain/entities/product_entity.dart';
import '../../../../core/widgets/loading_widget.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormPage({super.key, this.productId});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final products = ref.read(productsStateProvider).valueOrNull ?? [];
        final product = products.firstWhere((p) => p.id == widget.productId);
        _nameController.text = product.name;
        _descController.text = product.description ?? '';
        _priceController.text = product.price.toStringAsFixed(2);
        _stockController.text = product.stock.toString();
        setState(() {
          _isActive = product.isActive;
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _submit(String barbershopId) {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descController.text.trim();
      final price = double.parse(_priceController.text);
      final stock = int.parse(_stockController.text);

      if (widget.productId != null) {
        final updated = ProductEntity(
          id: widget.productId!,
          barbershopId: barbershopId,
          name: name,
          description: description.isEmpty ? null : description,
          price: price,
          stock: stock,
          isActive: _isActive,
        );

        ref
            .read(productsStateProvider.notifier)
            .updateProductDetails(updated)
            .then((_) {
          if (!mounted) return;
          Navigator.pop(context);
        });
      } else {
        final created = ProductEntity(
          id: const Uuid().v4(),
          barbershopId: barbershopId,
          name: name,
          description: description.isEmpty ? null : description,
          price: price,
          stock: stock,
          isActive: true,
        );

        ref
            .read(productsStateProvider.notifier)
            .addProduct(created)
            .then((_) {
          if (!mounted) return;
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final isEdit = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('No se encontró contexto de la barbería.'));
          }

          final shopId = barbershop.id;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Información del Producto', style: AppTextStyles.h4),
                        const SizedBox(height: AppSizes.lg),

                        // Name
                        AppTextField(
                          label: 'Nombre del Producto',
                          controller: _nameController,
                          prefixIcon: Icons.shopping_bag_outlined,
                          validator: (val) => Validators.required(val, 'El nombre del producto'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Description
                        AppTextField(
                          label: 'Descripción (Opcional)',
                          controller: _descController,
                          prefixIcon: Icons.description_outlined,
                          maxLines: 2,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Price
                        AppTextField(
                          label: 'Precio de Venta',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.attach_money_outlined,
                          validator: (val) => Validators.required(val, 'El precio'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Stock
                        AppTextField(
                          label: 'Stock en Inventario',
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.numbers_outlined,
                          validator: (val) => Validators.required(val, 'El stock'),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // Status Toggle (if editing)
                        if (isEdit) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Producto Activo', style: AppTextStyles.bodySm),
                              Switch(
                                value: _isActive,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => _isActive = val),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.lg),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  AppButton(
                    text: isEdit ? 'Guardar Cambios' : 'Registrar Producto',
                    onPressed: () => _submit(shopId),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
