import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/services_provider.dart';
import '../../domain/entities/service_entity.dart';

class ServiceFormPage extends ConsumerStatefulWidget {
  final String? serviceId;

  const ServiceFormPage({super.key, this.serviceId});

  @override
  ConsumerState<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends ConsumerState<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isActive = true;
  ServiceEntity? _existingService;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _initFields(List<ServiceEntity> services) {
    if (!_isInitialized && widget.serviceId != null) {
      _existingService = services.firstWhere((s) => s.id == widget.serviceId);
      _nameController.text = _existingService!.name;
      _descriptionController.text = _existingService!.description ?? '';
      _priceController.text = _existingService!.price.toString();
      _durationController.text = _existingService!.durationMinutes.toString();
      _isActive = _existingService!.isActive;
      _isInitialized = true;
    }
  }

  void _submit(String barbershopId) {
    if (_formKey.currentState!.validate()) {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final int duration = int.tryParse(_durationController.text) ?? 30;

      if (widget.serviceId == null) {
        final newService = ServiceEntity(
          id: const Uuid().v4(),
          barbershopId: barbershopId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          price: price,
          durationMinutes: duration,
          isActive: _isActive,
        );
        ref.read(servicesStateProvider.notifier).addService(newService).then((_) {
          if (!mounted) return;
          context.pop();
        });
      } else {
        final updated = _existingService!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          price: price,
          durationMinutes: duration,
          isActive: _isActive,
        );
        ref.read(servicesStateProvider.notifier).updateServiceDetails(updated).then((_) {
          if (!mounted) return;
          context.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final servicesAsync = ref.watch(servicesStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceId == null ? 'Nuevo Servicio' : 'Editar Servicio'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('Error: No se encontró contexto de la barbería.'));
          }

          servicesAsync.whenData((list) => _initFields(list));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Detalles del Servicio', style: AppTextStyles.h3),
                        const SizedBox(height: AppSizes.lg),

                        // Name
                        AppTextField(
                          label: 'Nombre del Servicio',
                          controller: _nameController,
                          prefixIcon: Icons.content_cut_rounded,
                          validator: (val) => Validators.required(val, 'El nombre del servicio'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Description
                        AppTextField(
                          label: 'Descripción (Opcional)',
                          controller: _descriptionController,
                          prefixIcon: Icons.description_outlined,
                          maxLines: 3,
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Precios & Tiempos', style: AppTextStyles.h4),
                        const SizedBox(height: AppSizes.lg),

                        // Price
                        AppTextField(
                          label: 'Precio Base (${barbershop.currencySymbol})',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.monetization_on_outlined,
                          validator: (val) => Validators.nonNegativeNumber(val, 'El precio'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Duration
                        AppTextField(
                          label: 'Duración (Minutos)',
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.access_time_rounded,
                          validator: Validators.duration,
                          hint: 'Ej: 15, 30, 45, 60',
                          textInputAction: TextInputAction.done,
                        ),

                        // Status toggle
                        if (widget.serviceId != null) ...[
                          const SizedBox(height: AppSizes.md),
                          SwitchListTile(
                            title: const Text('Servicio Activo'),
                            subtitle: const Text('Si se desactiva, no podrá agendarse en nuevas citas.'),
                            value: _isActive,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              setState(() {
                                _isActive = val;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  AppButton(
                    text: AppStrings.save,
                    onPressed: () => _submit(barbershop.id),
                    isLoading: servicesAsync.isLoading,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
