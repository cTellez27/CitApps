import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../employees/domain/entities/employee_entity.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../providers/appointments_provider.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_service_entity.dart';
import '../../domain/entities/appointment_product_entity.dart';

class AppointmentDetailPage extends ConsumerWidget {
  final String appointmentId;

  const AppointmentDetailPage({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);
    final servicesAsync = ref.watch(servicesStateProvider);
    final productsAsync = ref.watch(productsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cita'),
      ),
      body: appointmentsAsync.when(
        data: (list) {
          final appt = list.cast<AppointmentEntity?>().firstWhere(
                (a) => a?.id == appointmentId,
                orElse: () => null,
              );

          if (appt == null) {
            return const Center(
              child: Text('Cita no encontrada'),
            );
          }

          // Compute effective status
          final now = DateTime.now();
          final isHappening =
              (appt.status == 'pending' || appt.status == 'confirmed') &&
                  now.isAfter(appt.startTime) &&
                  now.isBefore(appt.endTime);
          final isEnded =
              (appt.status == 'pending' || appt.status == 'confirmed' || appt.status == 'in_progress') &&
                  (now.isAfter(appt.endTime) || now.isAtSameMomentAs(appt.endTime));

          final effectiveStatus = isEnded
              ? 'completed'
              : isHappening
                  ? 'in_progress'
                  : appt.status;

          final statusLabel = switch (effectiveStatus) {
            'pending' => 'Pendiente',
            'confirmed' => 'Confirmada',
            'in_progress' => 'En Proceso',
            'completed' => 'Completada',
            'cancelled' => 'Cancelada',
            _ => effectiveStatus,
          };

          final statusColor = switch (effectiveStatus) {
            'pending' => Colors.orange,
            'confirmed' => AppColors.success,
            'in_progress' => const Color(0xFF42A5F5),
            'completed' => Colors.green,
            'cancelled' => AppColors.error,
            _ => Colors.white,
          };

          final barberoName = employeesAsync.maybeWhen(
            data: (employees) => employees
                .firstWhere(
                  (e) => e.id == appt.employeeId,
                  orElse: () => const EmployeeEntity(
                    id: '',
                    barbershopId: '',
                    fullName: 'Desconocido',
                    role: UserRole.barber,
                  ),
                )
                .fullName,
            orElse: () => 'Cargando...',
          );

          // Watch specific linked services & products for this appointment
          final linkedServicesAsync = ref.watch(appointmentServicesProvider(appt.id));
          final linkedProductsAsync = ref.watch(appointmentProductsProvider(appt.id));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Status banner ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.md,
                    horizontal: AppSizes.lg,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_statusIcon(effectiveStatus), color: statusColor, size: 20),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        statusLabel,
                        style: AppTextStyles.labelLg.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // ── Appointment info ──
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información de la Cita', style: AppTextStyles.h4),
                      const Divider(height: AppSizes.xl),
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Cliente',
                        value: appt.customerName,
                      ),
                      if (appt.customerPhone != null) ...[
                        const SizedBox(height: AppSizes.sm),
                        _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Teléfono',
                          value: appt.customerPhone!,
                        ),
                      ],
                      if (appt.customerEmail != null) ...[
                        const SizedBox(height: AppSizes.sm),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: appt.customerEmail!,
                        ),
                      ],
                      const SizedBox(height: AppSizes.sm),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'Barbero',
                        value: barberoName,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Fecha',
                        value: DateFormat('EEEE d \'de\' MMMM yyyy', 'es').format(appt.startTime),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Horario',
                        value: '${AppDateUtils.formatTime(appt.startTime)} — ${AppDateUtils.formatTime(appt.endTime)}',
                      ),
                      if (appt.notes != null && appt.notes!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.sm),
                        _InfoRow(
                          icon: Icons.note_alt_outlined,
                          label: 'Notas',
                          value: appt.notes!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // ── Desglose de Consumos ──
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Detalle del Cobro', style: AppTextStyles.h4),
                          // Only allow additions if not completed/cancelled
                          if (effectiveStatus != 'completed' && effectiveStatus != 'cancelled')
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                              tooltip: 'Agregar Consumo',
                              onSelected: (val) {
                                if (val == 'service') {
                                  _showAddServiceModal(context, ref, appt.id, servicesAsync);
                                } else if (val == 'product') {
                                  _showAddProductModal(context, ref, appt.id, productsAsync);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'service',
                                  child: Row(
                                    children: [
                                      Icon(Icons.content_cut_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text('Servicio Extra'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'product',
                                  child: Row(
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Producto'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const Divider(height: AppSizes.lg),

                      // Linked Services
                      linkedServicesAsync.when(
                        data: (services) {
                          if (services.isEmpty) return const SizedBox.shrink();
                          final catalog = servicesAsync.valueOrNull ?? [];
                          final canDelete = effectiveStatus != 'completed' && effectiveStatus != 'cancelled';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: services.map((ls) {
                              final name = catalog
                                  .firstWhere((s) => s.id == ls.serviceId,
                                      orElse: () => ServiceEntity(id: '', name: 'Servicio Extra', price: ls.price, durationMinutes: 0, barbershopId: ''))
                                  .name;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.content_cut_rounded, size: 14, color: AppColors.textSecondaryDark),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text(name, style: AppTextStyles.bodyMd, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(CurrencyUtils.format(ls.price), style: AppTextStyles.labelMd),
                                        if (canDelete)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                                            tooltip: 'Eliminar Servicio',
                                            onPressed: () {
                                              ref.read(appointmentsStateProvider.notifier).removeExtraService(appt.id, ls.serviceId);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const LoadingWidget(),
                        error: (e, _) => Text('Error al cargar servicios: $e'),
                      ),

                      // Linked Products
                      linkedProductsAsync.when(
                        data: (products) {
                          if (products.isEmpty) return const SizedBox.shrink();
                          final catalog = productsAsync.valueOrNull ?? [];
                          final canDelete = effectiveStatus != 'completed' && effectiveStatus != 'cancelled';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              ...products.map((lp) {
                                final name = catalog
                                    .firstWhere((p) => p.id == lp.productId,
                                        orElse: () => ProductEntity(id: '', name: 'Producto Extra', price: lp.price, stock: 0, barbershopId: ''))
                                    .name;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.shopping_bag_outlined, size: 14, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text('$name (x${lp.quantity})', style: AppTextStyles.bodyMd, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(CurrencyUtils.format(lp.price * lp.quantity), style: AppTextStyles.labelMd),
                                          if (canDelete)
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                                              tooltip: 'Eliminar Producto',
                                              onPressed: () {
                                                ref.read(appointmentsStateProvider.notifier).removeExtraProduct(appt.id, lp.productId);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (e, _) => Text('Error al cargar productos: $e'),
                      ),

                      const Divider(height: AppSizes.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total a Cobrar', style: AppTextStyles.labelLg),
                          Text(
                            CurrencyUtils.format(appt.totalPrice),
                            style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xl),

                // ── Action Buttons ──
                if (effectiveStatus == 'in_progress') ...[
                  AppButton(
                    text: '✓ Finalizar Servicio',
                    onPressed: () => _showCompleteDialog(context, ref, appt, linkedServicesAsync.valueOrNull ?? [], linkedProductsAsync.valueOrNull ?? [], servicesAsync.valueOrNull ?? [], productsAsync.valueOrNull ?? [], barberoName),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                if (effectiveStatus == 'pending') ...[
                  AppButton(
                    text: '▶ Marcar como En Proceso',
                    onPressed: () {
                      ref.read(appointmentsStateProvider.notifier).markInProgress(appt.id);
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                if (effectiveStatus == 'completed') ...[
                  AppButton(
                    text: '🧾 Ver Reporte de Cobro',
                    onPressed: () => _showBillingReport(
                      context,
                      appt,
                      linkedServicesAsync.valueOrNull ?? [],
                      linkedProductsAsync.valueOrNull ?? [],
                      servicesAsync.valueOrNull ?? [],
                      productsAsync.valueOrNull ?? [],
                      barberoName,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
                if (effectiveStatus != 'cancelled' && effectiveStatus != 'completed')
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancelar Cita'),
                    onPressed: () => _showCancelDialog(context, ref, appt),
                  ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'pending' => Icons.schedule_rounded,
      'confirmed' => Icons.check_circle_outline,
      'in_progress' => Icons.play_circle_outline_rounded,
      'completed' => Icons.task_alt_rounded,
      'cancelled' => Icons.cancel_outlined,
      _ => Icons.info_outline,
    };
  }

  // ── Extra Additions Modals ──

  void _showAddServiceModal(BuildContext context, WidgetRef ref, String appointmentId, AsyncValue<List<ServiceEntity>> servicesAsync) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final services = servicesAsync.valueOrNull ?? [];
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Agregar Servicio Extra', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.md),
                  if (services.isEmpty)
                    const Center(child: Text('No hay servicios disponibles.'))
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: services.length,
                        itemBuilder: (_, index) {
                          final s = services[index];
                          return ListTile(
                            leading: const Icon(Icons.content_cut_rounded, color: AppColors.primary),
                            title: Text(s.name),
                            trailing: Text(CurrencyUtils.format(s.price)),
                            onTap: () {
                              ref.read(appointmentsStateProvider.notifier).addExtraService(appointmentId, s.id, s.price);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductModal(BuildContext context, WidgetRef ref, String appointmentId, AsyncValue<List<ProductEntity>> productsAsync) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final products = (productsAsync.valueOrNull ?? []).where((p) => p.isActive).toList();
        ProductEntity? selectedProduct;
        int quantity = 1;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                top: AppSizes.lg,
                left: AppSizes.lg,
                right: AppSizes.lg,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + AppSizes.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Agregar Producto', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.md),
                  if (products.isEmpty)
                    const Center(child: Text('No hay productos registrados en el inventario.'))
                  else ...[
                    DropdownButtonFormField<ProductEntity>(
                      value: selectedProduct,
                      isExpanded: true, // Prevents right overflow by constraining dropdown items
                      decoration: const InputDecoration(labelText: 'Producto'),
                      items: products.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(
                            '${p.name} - Stock: ${p.stock} (${CurrencyUtils.format(p.price)})',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedProduct = val;
                          quantity = 1; // reset quantity
                        });
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    if (selectedProduct != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cantidad:', style: AppTextStyles.bodyMd),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (quantity > 1) {
                                    setModalState(() => quantity--);
                                  }
                                },
                              ),
                              Text('$quantity', style: AppTextStyles.labelLg),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  if (quantity < selectedProduct!.stock) {
                                    setModalState(() => quantity++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        text: 'Agregar (${CurrencyUtils.format(selectedProduct!.price * quantity)})',
                        onPressed: () {
                          ref.read(appointmentsStateProvider.notifier).addExtraProduct(
                                appointmentId,
                                selectedProduct!.id,
                                selectedProduct!.price,
                                quantity,
                              );
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Dialogs ──

  void _showCompleteDialog(
      BuildContext context,
      WidgetRef ref,
      AppointmentEntity appt,
      List<AppointmentServiceEntity> linkedServices,
      List<AppointmentProductEntity> linkedProducts,
      List<ServiceEntity> catalogServices,
      List<ProductEntity> catalogProducts,
      String barberoName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finalizar Servicio'),
        content: const Text(
          '¿Confirmas que el servicio fue completado? '
          'Se generará el reporte de cobro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(appointmentsStateProvider.notifier)
                  .completeAppointment(appt.id)
                  .then((_) {
                if (!ctx.mounted) return;
                _showBillingReport(context, appt, linkedServices, linkedProducts, catalogServices, catalogProducts, barberoName);
              });
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, AppointmentEntity appt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Text('¿Cancelar la cita de ${appt.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(appointmentsStateProvider.notifier)
                  .cancelBooking(appt.id)
                  .then((_) {
                if (!ctx.mounted) return;
                Navigator.pop(context);
              });
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showBillingReport(
      BuildContext context,
      AppointmentEntity appt,
      List<AppointmentServiceEntity> linkedServices,
      List<AppointmentProductEntity> linkedProducts,
      List<ServiceEntity> catalogServices,
      List<ProductEntity> catalogProducts,
      String barberoName) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reporte de Cobro', style: AppTextStyles.h3),
                        Text('Ticket final', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondaryDark)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: AppSizes.xl),

                // Info rows
                _BillRow(label: 'Cliente', value: appt.customerName),
                if (barberoName.isNotEmpty) _BillRow(label: 'Barbero', value: barberoName),
                _BillRow(
                  label: 'Fecha',
                  value: DateFormat('dd/MM/yyyy', 'es').format(appt.startTime),
                ),
                _BillRow(
                  label: 'Hora',
                  value: '${AppDateUtils.formatTime(appt.startTime)} — ${AppDateUtils.formatTime(appt.endTime)}',
                ),
                const Divider(height: AppSizes.xl),

                // Services desglosados
                if (linkedServices.isNotEmpty) ...[
                  Text('Servicios', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  ...linkedServices.map((ls) {
                    final name = catalogServices.firstWhere((s) => s.id == ls.serviceId, orElse: () => ServiceEntity(id: '', name: 'Servicio', price: ls.price, durationMinutes: 0, barbershopId: '')).name;
                    return _BillRow(label: name, value: CurrencyUtils.format(ls.price));
                  }),
                  const SizedBox(height: 8),
                ],

                // Products desglosados
                if (linkedProducts.isNotEmpty) ...[
                  Text('Productos', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  ...linkedProducts.map((lp) {
                    final name = catalogProducts.firstWhere((p) => p.id == lp.productId, orElse: () => ProductEntity(id: '', name: 'Producto', price: lp.price, stock: 0, barbershopId: '')).name;
                    return _BillRow(label: '$name (x${lp.quantity})', value: CurrencyUtils.format(lp.price * lp.quantity));
                  }),
                  const SizedBox(height: 8),
                ],

                const Divider(height: AppSizes.xl),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Cobrado', style: AppTextStyles.labelLg),
                    Text(
                      CurrencyUtils.format(appt.totalPrice),
                      style: AppTextStyles.h2.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xl),

                FilledButton.icon(
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Listo'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper Widgets ──

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryDark),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTextStyles.bodyMd,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;

  const _BillRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondaryDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Text(value, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}
