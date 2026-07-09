import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../providers/services_provider.dart';
import '../../domain/entities/service_entity.dart';

class ServiceDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ServiceDetailPage({super.key, required this.id});

  @override
  ConsumerState<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends ConsumerState<ServiceDetailPage> {
  List<String> _localSelectedEmployeeIds = [];
  bool _isAssignedInitialized = false;

  void _deactivateService(ServiceEntity service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar Servicio'),
        content: Text('¿Estás seguro de que deseas desactivar ${service.name}? Ya no se podrá agendar en futuras citas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(servicesStateProvider.notifier).deactivateService(service.id).then((_) {
                if (!context.mounted) return;
                context.pop();
              });
            },
            child: const Text(AppStrings.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _saveAssignments() {
    ref
        .read(serviceEmployeesProvider(widget.id).notifier)
        .updateAssignments(_localSelectedEmployeeIds)
        .then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Asignación de barberos actualizada'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final servicesAsync = ref.watch(servicesStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);
    final assignedAsync = ref.watch(serviceEmployeesProvider(widget.id));

    final isOwnerOrAdmin = authState is Authenticated &&
        (authState.user.role == UserRole.owner || authState.user.role == UserRole.admin);

    return servicesAsync.when(
      data: (services) {
        final service = services.firstWhere(
          (s) => s.id == widget.id,
          orElse: () => const ServiceEntity(
            id: '',
            barbershopId: '',
            name: 'Desconocido',
            price: 0.0,
            durationMinutes: 30,
          ),
        );

        if (service.id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Servicio no encontrado.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(service.name),
            actions: [
              if (isOwnerOrAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('${RouteNames.services}/${service.id}/edit'),
                ),
                if (service.isActive)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    onPressed: () => _deactivateService(service),
                  ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Ficha del Servicio
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: AppTextStyles.h2,
                            ),
                          ),
                          Chip(
                            label: Text(service.isActive ? 'Activo' : 'Inactivo'),
                            backgroundColor: service.isActive ? AppColors.success : AppColors.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        '${service.durationMinutes} minutos • ${CurrencyUtils.format(service.price)}',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                      ),
                      if (service.description != null && service.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSizes.md),
                        Text(
                          service.description!,
                          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),

                // 2. Personal Capacitado (N-N asignación)
                Text('Personal Capacitado', style: AppTextStyles.h3),
                const SizedBox(height: AppSizes.sm),

                assignedAsync.when(
                  data: (assignedIds) {
                    if (!_isAssignedInitialized) {
                      _localSelectedEmployeeIds = List.from(assignedIds);
                      _isAssignedInitialized = true;
                    }

                    return employeesAsync.when(
                      data: (employees) {
                        // Filter active staff members who are barbers or admins/owners
                        final barbers = employees.where((e) => e.isActive).toList();

                        if (barbers.isEmpty) {
                          return const EmptyStateWidget(
                            icon: Icons.people_outline_rounded,
                            title: 'No hay barberos registrados',
                            subtitle: 'Registra empleados primero para poder asignarlos.',
                          );
                        }

                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...barbers.map((barber) {
                                final isSelected = _localSelectedEmployeeIds.contains(barber.id);

                                return CheckboxListTile(
                                  title: Text(barber.fullName),
                                  subtitle: Text(
                                    barber.role == UserRole.barber
                                        ? 'Barbero'
                                        : barber.role == UserRole.admin
                                            ? 'Administrador'
                                            : 'Dueño',
                                  ),
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: !isOwnerOrAdmin
                                      ? null
                                      : (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              _localSelectedEmployeeIds.add(barber.id);
                                            } else {
                                              _localSelectedEmployeeIds.remove(barber.id);
                                            }
                                          });
                                        },
                                );
                              }),
                              if (isOwnerOrAdmin) ...[
                                const SizedBox(height: AppSizes.md),
                                AppButton(
                                  text: 'Actualizar Asignaciones',
                                  onPressed: _saveAssignments,
                                  isLoading: assignedAsync.isLoading,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                      loading: () => const LoadingWidget(),
                      error: (e, _) => AppErrorWidget(message: e.toString()),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (e, _) => AppErrorWidget(
                    message: e.toString(),
                    onRetry: () {
                      _isAssignedInitialized = false;
                      ref.invalidate(serviceEmployeesProvider(widget.id));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(body: AppErrorWidget(message: e.toString())),
    );
  }
}
