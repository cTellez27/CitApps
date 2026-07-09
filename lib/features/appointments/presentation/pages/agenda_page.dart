import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../employees/domain/entities/employee_entity.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/appointments_provider.dart';
import '../../domain/entities/appointment_entity.dart';

class AgendaPage extends ConsumerStatefulWidget {
  const AgendaPage({super.key});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  String? _selectedEmployeeId; // Filtering by employee

  Future<void> _selectDate(BuildContext context) async {
    final activeDate = ref.read(activeDateProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: activeDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      helpText: 'Seleccionar Fecha de Agenda',
    );
    if (picked != null) {
      ref.read(activeDateProvider.notifier).state = picked;
    }
  }

  void _confirmCancel(AppointmentEntity appt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Cita'),
        content: Text('¿Estás seguro de que deseas cancelar la cita de ${appt.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(appointmentsStateProvider.notifier).cancelBooking(appt.id).then((_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita cancelada con éxito'),
                    backgroundColor: AppColors.success,
                  ),
                );
              });
            },
            child: const Text('Confirmar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeDate = ref.watch(activeDateProvider);
    final appointmentsAsync = ref.watch(appointmentsStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);
    final authState = ref.watch(authNotifierProvider);
    final barbershopAsync = ref.watch(barbershopStateProvider);

    final isOwnerOrAdmin = authState is Authenticated &&
        (authState.user.role == UserRole.owner || authState.user.role == UserRole.admin);

    // Format current selected date
    final dateLabel = DateFormat('EEEE, d \'de\' MMMM', 'es').format(activeDate);

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: AppColors.backgroundDark,
          child: Column(
            children: [
              // Header
              barbershopAsync.when(
                data: (barbershop) => UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: AppColors.cardDark,
                    border: Border(
                      bottom: BorderSide(color: AppColors.primary, width: 1),
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: AppColors.backgroundDark,
                    child: Text(
                      barbershop?.name[0].toUpperCase() ?? 'C',
                      style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  accountName: Text(
                    barbershop?.name ?? 'Mi Barbería',
                    style: AppTextStyles.labelLg.copyWith(color: AppColors.textPrimaryDark),
                  ),
                  accountEmail: Text(
                    switch (authState) {
                      Authenticated(user: final u) => '${u.fullName} (${u.role == UserRole.owner ? 'Propietario' : 'Personal'})',
                      _ => '',
                    },
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondaryDark),
                  ),
                ),
                loading: () => const DrawerHeader(child: Center(child: CircularProgressIndicator())),
                error: (_, _) => const DrawerHeader(child: Text('Error')),
              ),

              // Drawer Items
              ListTile(
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                title: const Text('Agenda de Citas'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                title: const Text('Personal y Barberos'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/employees');
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_cut_rounded, color: AppColors.primary),
                title: const Text('Catálogo de Servicios'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/services');
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline_rounded, color: AppColors.primary),
                title: const Text('Directorio de Clientes'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/clients');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                title: const Text('Reportes de Servicios'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/reports');
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                title: const Text('Inventario de Productos'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/inventory');
                },
              ),

              // Conditional Reports (Owner or Admin only)
              if (isOwnerOrAdmin)
                barbershopAsync.maybeWhen(
                  data: (shop) => shop != null && shop.enableCommissions
                      ? ListTile(
                          leading: const Icon(Icons.analytics_outlined, color: AppColors.primary),
                          title: const Text('Comisiones y Ganancias'),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/reports/commissions');
                          },
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),

              // Settings (Owner or Admin only)
              if (isOwnerOrAdmin)
                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                  title: const Text('Ajustes de Barbería'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),

              const Spacer(),
              const Divider(),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authNotifierProvider.notifier).signOut();
                },
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Agenda de Citas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            tooltip: 'Cambiar Fecha',
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Selector de fecha horizontal rápido
          Container(
            color: AppColors.cardDark,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                        onPressed: () {
                          ref.read(activeDateProvider.notifier).state =
                              activeDate.subtract(const Duration(days: 1));
                        },
                      ),
                      Text(
                        dateLabel[0].toUpperCase() + dateLabel.substring(1),
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onPressed: () {
                          ref.read(activeDateProvider.notifier).state =
                              activeDate.add(const Duration(days: 1));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.sm),

                // 2. Filtro rápido de Empleados/Barberos
                employeesAsync.when(
                  data: (employees) {
                    final activeEmployees = employees.where((e) => e.isActive).toList();
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: AppSizes.xs),
                            child: ChoiceChip(
                              label: const Text('Todos'),
                              selected: _selectedEmployeeId == null,
                              onSelected: (selected) {
                                if (selected) setState(() => _selectedEmployeeId = null);
                              },
                            ),
                          ),
                          ...activeEmployees.map((emp) {
                            return Padding(
                              padding: const EdgeInsets.only(right: AppSizes.xs),
                              child: ChoiceChip(
                                label: Text(emp.fullName),
                                selected: _selectedEmployeeId == emp.id,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedEmployeeId = selected ? emp.id : null;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // 3. Listado de citas agendadas
          Expanded(
            child: appointmentsAsync.when(
              data: (list) {
                // Filtrar por empleado si aplica
                var filtered = list;
                if (_selectedEmployeeId != null) {
                  filtered = filtered.where((a) => a.employeeId == _selectedEmployeeId).toList();
                }

                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.calendar_today_rounded,
                    title: 'No hay citas agendadas',
                    subtitle: 'Presiona el botón "+" para reservar una cita.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.md),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final appt = filtered[index];

                    // Determinar el barbero
                    final barberoName = employeesAsync.maybeWhen(
                      data: (list) => list
                          .firstWhere((e) => e.id == appt.employeeId,
                              orElse: () => const EmployeeEntity(
                                    id: '',
                                    barbershopId: '',
                                    fullName: 'Desconocido',
                                    role: UserRole.barber,
                                  ))
                          .fullName,
                      orElse: () => 'Cargando...',
                    );

                     // Compute effective status — show correct transition locally
                     final now = DateTime.now();
                     final isHappening = (appt.status == 'pending' ||
                             appt.status == 'confirmed') &&
                         now.isAfter(appt.startTime) &&
                         now.isBefore(appt.endTime);
                     final isEnded = (appt.status == 'pending' ||
                             appt.status == 'confirmed' ||
                             appt.status == 'in_progress') &&
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

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/schedule/${appt.id}'),
                      child: Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.md),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${AppDateUtils.formatTime(appt.startTime)} - ${AppDateUtils.formatTime(appt.endTime)}',
                                  style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.sm,
                                    vertical: AppSizes.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: statusColor, width: 0.5),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: AppSizes.md),
                            Text(appt.customerName, style: AppTextStyles.h4),
                            const SizedBox(height: AppSizes.xs),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondaryDark),
                                const SizedBox(width: AppSizes.xs),
                                Text(appt.customerPhone ?? 'Sin teléfono', style: AppTextStyles.bodySm),
                                const SizedBox(width: AppSizes.lg),
                                const Icon(Icons.badge_outlined, size: 14, color: AppColors.textSecondaryDark),
                                const SizedBox(width: AppSizes.xs),
                                Text(barberoName, style: AppTextStyles.bodySm),
                              ],
                            ),
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ${CurrencyUtils.format(appt.totalPrice)}',
                                  style: AppTextStyles.labelMd,
                                ),
                                if (isOwnerOrAdmin && appt.status != 'cancelled')
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
                                    tooltip: 'Cancelar Cita',
                                    onPressed: () => _confirmCancel(appt),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ), // Card
                  ); // InkWell
                },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(appointmentsStateProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.schedule),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
