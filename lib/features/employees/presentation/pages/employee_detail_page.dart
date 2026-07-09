import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/employees_provider.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/entities/employee_schedule_entity.dart';

class EmployeeDetailPage extends ConsumerStatefulWidget {
  final String id;

  const EmployeeDetailPage({super.key, required this.id});

  @override
  ConsumerState<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends ConsumerState<EmployeeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EmployeeScheduleEntity> _localSchedules = [];
  bool _isScheduleInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _deactivateEmployee(EmployeeEntity employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar Empleado'),
        content: Text('¿Estás seguro de que deseas desactivar a ${employee.fullName}? No podrá recibir más citas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(employeesStateProvider.notifier).deactivateEmployee(employee.id).then((_) {
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

  void _saveSchedule() {
    // Validate close time > open time
    for (final sch in _localSchedules) {
      if (sch.isWorking) {
        final open = _parseTime(sch.startTime);
        final close = _parseTime(sch.endTime);
        if (open.isAfter(close) || open.isAtSameMomentAs(close)) {
          final dayName = AppDateUtils.dayNameFull(sch.dayOfWeek == 0 ? 7 : sch.dayOfWeek);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error en $dayName: El fin de turno debe ser posterior al inicio.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
    }

    ref.read(employeeScheduleProvider(widget.id).notifier).saveSchedule(_localSchedules).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario de trabajo personalizado actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hours, minutes);
  }

  Future<void> _selectTime(int index, bool isStartTime) async {
    final sch = _localSchedules[index];
    final initialTimeStr = isStartTime ? sch.startTime : sch.endTime;
    final parts = initialTimeStr.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isStartTime ? 'Inicio de Turno' : 'Fin de Turno',
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      setState(() {
        _localSchedules[index] = isStartTime
            ? sch.copyWith(startTime: formattedTime)
            : sch.copyWith(endTime: formattedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);

    final isOwnerOrAdmin = authState is Authenticated &&
        (authState.user.role == UserRole.owner || authState.user.role == UserRole.admin);

    return employeesAsync.when(
      data: (employees) {
        final employee = employees.firstWhere(
          (e) => e.id == widget.id,
          orElse: () => const EmployeeEntity(
            id: '',
            barbershopId: '',
            fullName: 'Desconocido',
            role: UserRole.barber,
          ),
        );

        if (employee.id.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Empleado no encontrado.')),
          );
        }

        final roleLabel = switch (employee.role) {
          UserRole.owner => AppStrings.owner,
          UserRole.admin => AppStrings.admin,
          UserRole.barber => AppStrings.barber,
          UserRole.receptionist => AppStrings.receptionist,
        };

        return Scaffold(
          appBar: AppBar(
            title: Text(employee.fullName),
            actions: [
              if (isOwnerOrAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('${RouteNames.employees}/${employee.id}/edit'),
                ),
                if (employee.isActive)
                  IconButton(
                    icon: const Icon(Icons.person_off_outlined, color: AppColors.error),
                    onPressed: () => _deactivateEmployee(employee),
                  ),
              ],
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondaryDark,
              tabs: const [
                Tab(icon: Icon(Icons.badge_outlined), text: 'Ficha'),
                Tab(icon: Icon(Icons.access_time_rounded), text: 'Horario'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // ── TAB FICHA ──
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.cardDark,
                            child: Text(
                              employee.fullName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32, color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(employee.fullName, style: AppTextStyles.h2),
                          Text(roleLabel, style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary)),
                          const SizedBox(height: AppSizes.md),
                          Chip(
                            label: Text(employee.isActive ? 'Activo' : 'Inactivo'),
                            backgroundColor: employee.isActive ? AppColors.success : AppColors.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Información de Contacto', style: AppTextStyles.h4),
                          const SizedBox(height: AppSizes.md),
                          ListTile(
                            leading: const Icon(Icons.phone_outlined),
                            title: const Text('Teléfono'),
                            subtitle: Text(employee.phone ?? 'No registrado'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email_outlined),
                            title: const Text('Correo electrónico'),
                            subtitle: Text(employee.email ?? 'No registrado'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                    // Mostrar comisiones sólo si está activado globalmente
                    barbershopAsync.when(
                      data: (barberSettings) {
                        if (barberSettings != null && barberSettings.enableCommissions) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSizes.md),
                            child: AppCard(
                              child: ListTile(
                                leading: const Icon(Icons.monetization_on_outlined, color: AppColors.primary),
                                title: const Text('Porcentaje de Comisión'),
                                subtitle: Text('${employee.commissionRate}% por servicio'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // ── TAB HORARIO ──
              barbershopAsync.when(
                data: (barbershop) {
                  if (barbershop == null) {
                    return const Center(child: Text('Error al cargar ajustes globales.'));
                  }

                  // Si el horario de empleado está desactivado globalmente
                  if (!barbershop.enableEmployeeSchedules) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSizes.xl),
                      child: EmptyStateWidget(
                        icon: Icons.calendar_today_rounded,
                        title: 'Horarios individuales desactivados',
                        subtitle: 'Este barbero utiliza el horario global de apertura y cierre de la barbería.',
                      ),
                    );
                  }

                  // Si el horario de empleado está activado globalmente, cargamos su horario
                  final scheduleAsync = ref.watch(employeeScheduleProvider(employee.id));

                  return scheduleAsync.when(
                    data: (schedules) {
                      if (!_isScheduleInitialized) {
                        if (schedules.isEmpty) {
                          // Generamos horario local basado en el de la barbería como fallback
                          _localSchedules = [];
                          for (int i = 0; i <= 6; i++) {
                            _localSchedules.add(
                              EmployeeScheduleEntity(
                                id: '',
                                employeeId: employee.id,
                                dayOfWeek: i,
                                startTime: '09:00:00',
                                endTime: '18:00:00',
                                isWorking: i != 0, // Cerrado los domingos por defecto
                              ),
                            );
                          }
                        } else {
                          _localSchedules = List.from(schedules);
                        }
                        _isScheduleInitialized = true;
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSizes.lg),
                              itemCount: _localSchedules.length,
                              itemBuilder: (context, index) {
                                final sch = _localSchedules[index];
                                final dayName = AppDateUtils.dayNameFull(
                                  sch.dayOfWeek == 0 ? 7 : sch.dayOfWeek,
                                );

                                return Card(
                                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.md,
                                      vertical: AppSizes.sm,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            dayName,
                                            style: AppTextStyles.labelLg,
                                          ),
                                        ),
                                        Switch(
                                          value: sch.isWorking,
                                          activeThumbColor: AppColors.primary,
                                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                                          onChanged: !isOwnerOrAdmin
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    _localSchedules[index] = sch.copyWith(isWorking: val);
                                                  });
                                                },
                                        ),
                                        const SizedBox(width: AppSizes.md),
                                        if (sch.isWorking) ...[
                                          TextButton(
                                            onPressed: !isOwnerOrAdmin
                                                ? null
                                                : () => _selectTime(index, true),
                                            child: Text(
                                              AppDateUtils.formatTimeString(sch.startTime),
                                              style: TextStyle(
                                                color: isOwnerOrAdmin ? AppColors.primary : Colors.white,
                                              ),
                                            ),
                                          ),
                                          const Text('a'),
                                          TextButton(
                                            onPressed: !isOwnerOrAdmin
                                                ? null
                                                : () => _selectTime(index, false),
                                            child: Text(
                                              AppDateUtils.formatTimeString(sch.endTime),
                                              style: TextStyle(
                                                color: isOwnerOrAdmin ? AppColors.primary : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ] else
                                          const Expanded(
                                            flex: 3,
                                            child: Text(
                                              'No Laboral',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: AppColors.error),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isOwnerOrAdmin)
                            Padding(
                              padding: const EdgeInsets.all(AppSizes.lg),
                              child: AppButton(
                                text: 'Guardar Horario',
                                onPressed: _saveSchedule,
                                isLoading: scheduleAsync.isLoading,
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (e, _) => AppErrorWidget(
                      message: e.toString(),
                      onRetry: () {
                        _isScheduleInitialized = false;
                        ref.invalidate(employeeScheduleProvider(employee.id));
                      },
                    ),
                  );
                },
                loading: () => const LoadingWidget(),
                error: (e, _) => AppErrorWidget(message: e.toString()),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(body: AppErrorWidget(message: e.toString())),
    );
  }
}
