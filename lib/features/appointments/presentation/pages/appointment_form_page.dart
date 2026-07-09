import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../clients/presentation/providers/clients_provider.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/appointments_provider.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_service_entity.dart';

class AppointmentFormPage extends ConsumerStatefulWidget {
  const AppointmentFormPage({super.key});

  @override
  ConsumerState<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends ConsumerState<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedEmployeeId;
  final List<ServiceEntity> _selectedServices = [];
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedSlot;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Fecha de Reserva',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
    }
  }

  /// Opens a bottom sheet to search and select a client from the directory.
  void _openClientDirectory(BuildContext context, List<ClientEntity> allClients) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final clients = allClients.where((c) {
              final q = searchQuery.toLowerCase();
              return c.fullName.toLowerCase().contains(q) ||
                  (c.phone?.contains(q) ?? false);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                top: AppSizes.lg,
                left: AppSizes.lg,
                right: AppSizes.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSizes.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Seleccionar Cliente', style: AppTextStyles.h3),
                  const SizedBox(height: AppSizes.md),

                  // Search bar
                  TextField(
                    autofocus: false,
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o teléfono...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Client list
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(ctx).size.height * 0.60,
                    ),
                    child: clients.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSizes.xl),
                              child: Text(
                                searchQuery.isEmpty
                                    ? 'No hay clientes en el directorio'
                                    : 'No se encontraron coincidencias',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: clients.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final client = clients[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.cardDark,
                                  child: Text(
                                    client.fullName[0].toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary),
                                  ),
                                ),
                                title: Text(client.fullName, style: AppTextStyles.labelMd),
                                subtitle: Text(
                                  client.phone ?? 'Sin teléfono',
                                  style: AppTextStyles.bodySm,
                                ),
                                onTap: () {
                                  setState(() {
                                    _nameController.text = client.fullName;
                                    _phoneController.text = client.phone ?? '';
                                    _emailController.text = client.email ?? '';
                                  });
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

  void _submit(String barbershopId) {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un barbero.')),
      );
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona al menos un servicio.')),
      );
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una hora de cita.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final totalDuration =
          _selectedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes);
      final totalPrice =
          _selectedServices.fold<double>(0.0, (sum, s) => sum + s.price);
      final appointmentId = const Uuid().v4();

      final appointment = AppointmentEntity(
        id: appointmentId,
        barbershopId: barbershopId,
        employeeId: _selectedEmployeeId!,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        customerEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        startTime: _selectedSlot!,
        endTime: _selectedSlot!.add(Duration(minutes: totalDuration)),
        totalPrice: totalPrice,
        status: 'pending',
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final servicesList = _selectedServices
          .map((s) => AppointmentServiceEntity(
                appointmentId: appointmentId,
                serviceId: s.id,
                price: s.price,
              ))
          .toList();

      ref
          .read(appointmentsStateProvider.notifier)
          .bookAppointment(appointment: appointment, services: servicesList)
          .then((_) {
        if (!mounted) return;
        Navigator.pop(context);
      });
    }
  }

  /// Builds AM/PM time slot sections with alternating row colors.
  Widget _buildTimeSlotsSection(List<DateTime> slots) {
    final amSlots = slots.where((s) => s.hour < 12).toList();
    final pmSlots = slots.where((s) => s.hour >= 12).toList();

    Widget buildSlotGroup(
        String label, List<DateTime> groupSlots, Color accentColor) {
      if (groupSlots.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accentColor.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  label == 'AM'
                      ? Icons.wb_sunny_outlined
                      : Icons.wb_twilight_outlined,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(color: accentColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),

          // Slots grid with alternating row colors
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSizes.xs,
              mainAxisSpacing: AppSizes.xs,
              childAspectRatio: 2.2,
            ),
            itemCount: groupSlots.length,
            itemBuilder: (context, index) {
              final slot = groupSlots[index];
              final isSelected = _selectedSlot == slot;
              final rowIndex = index ~/ 4;
              final isAlternateRow = rowIndex % 2 == 1;

              final bgColor = isSelected
                  ? AppColors.primary
                  : isAlternateRow
                      ? AppColors.cardDark
                      : AppColors.surfaceDark;

              final textColor = isSelected
                  ? Colors.black
                  : accentColor.withAlpha(isAlternateRow ? 255 : 200);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSlot = isSelected ? null : slot;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : accentColor.withAlpha(60),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat('HH:mm').format(slot),
                      style: TextStyle(
                        color: textColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSlotGroup('AM', amSlots, const Color(0xFFFFA726)),
        if (amSlots.isNotEmpty && pmSlots.isNotEmpty)
          const SizedBox(height: AppSizes.md),
        buildSlotGroup('PM', pmSlots, const Color(0xFF42A5F5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);
    final servicesAsync = ref.watch(servicesStateProvider);
    final appointmentsAsync = ref.watch(appointmentsStateProvider);
    // Pre-load clients so the directory modal shows data immediately.
    final clientsList = ref.watch(clientsStateProvider).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Cita'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(
                child: Text('Error: No se encontró contexto de la barbería.'));
          }

          final totalDuration =
              _selectedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes);
          final totalPrice =
              _selectedServices.fold<double>(0.0, (sum, s) => sum + s.price);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Selector de Barberos
                  employeesAsync.when(
                    data: (employees) {
                      final activeBarbers =
                          employees.where((e) => e.isActive).toList();
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('1. Selecciona tu Barbero', style: AppTextStyles.h4),
                            const SizedBox(height: AppSizes.md),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedEmployeeId,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.badge_outlined),
                                labelText: 'Barbero',
                              ),
                              items: activeBarbers.map((b) {
                                return DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.fullName),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedEmployeeId = val;
                                  _selectedSlot = null;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (e, _) => AppErrorWidget(message: e.toString()),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // 2. Selector de Servicios
                  servicesAsync.when(
                    data: (services) {
                      final activeServices =
                          services.where((s) => s.isActive).toList();
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('2. Elige los Servicios', style: AppTextStyles.h4),
                            const SizedBox(height: AppSizes.sm),
                            ...activeServices.map((svc) {
                              final isChecked = _selectedServices.contains(svc);
                              return CheckboxListTile(
                                title: Text(svc.name),
                                subtitle: Text(
                                  '${svc.durationMinutes} min • ${CurrencyUtils.format(svc.price)}',
                                ),
                                activeColor: AppColors.primary,
                                value: isChecked,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedServices.add(svc);
                                    } else {
                                      _selectedServices.remove(svc);
                                    }
                                    _selectedSlot = null;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (e, _) => AppErrorWidget(message: e.toString()),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // 3. Selección de Fecha
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('3. Selecciona Fecha de Reserva', style: AppTextStyles.h4),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('EEEE, d \'de\' MMMM', 'es')
                                  .format(_selectedDate),
                              style: AppTextStyles.labelLg,
                            ),
                            TextButton.icon(
                              onPressed: () => _selectDate(context),
                              icon: const Icon(Icons.calendar_today_rounded,
                                  size: 16),
                              label: const Text('Elegir Día'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // 4. Horarios Disponibles — AM / PM
                  if (_selectedEmployeeId != null &&
                      _selectedServices.isNotEmpty) ...[
                    ref
                        .watch(
                          employeeAvailabilityProvider(
                            EmployeeAvailabilityQuery(
                              employeeId: _selectedEmployeeId!,
                              date: _selectedDate,
                            ),
                          ),
                        )
                        .when(
                          data: (slots) {
                            return AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('4. Horarios Disponibles',
                                          style: AppTextStyles.h4),
                                      Text(
                                        '${slots.length} libres',
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.textSecondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.md),
                                  if (slots.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: AppSizes.md),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.event_busy_outlined,
                                            color: AppColors.error,
                                            size: 36,
                                          ),
                                          const SizedBox(height: AppSizes.sm),
                                          Text(
                                            'No hay turnos disponibles para este día.',
                                            textAlign: TextAlign.center,
                                            style:
                                                AppTextStyles.bodySm.copyWith(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    _buildTimeSlotsSection(slots),
                                ],
                              ),
                            );
                          },
                          loading: () => const LoadingWidget(),
                          error: (e, _) => AppErrorWidget(message: e.toString()),
                        ),
                    const SizedBox(height: AppSizes.md),
                  ],

                  // 5. Datos de Contacto del Cliente
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header row with directory button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('5. Datos de Contacto', style: AppTextStyles.h4),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary.withAlpha(20),
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.xs,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: AppColors.primary.withAlpha(80),
                                  ),
                                ),
                              ),
                              onPressed: () => _openClientDirectory(
                                context,
                                clientsList,
                              ),
                              icon: const Icon(Icons.people_outline_rounded,
                                  size: 16),
                              label: const Text(
                                'Directorio',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: 'Nombre del Cliente',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) =>
                              Validators.required(val, 'El nombre del cliente'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: 'Teléfono',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: 'Correo Electrónico (Opcional)',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        AppTextField(
                          label: 'Notas adicionales',
                          controller: _notesController,
                          prefixIcon: Icons.note_alt_outlined,
                          maxLines: 2,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),

                  // 6. Resumen & Botón de Guardar
                  const SizedBox(height: AppSizes.xl),
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Acumulado:', style: AppTextStyles.bodySm),
                            Text(
                              CurrencyUtils.format(totalPrice),
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Duración Estimada:',
                                style: AppTextStyles.bodySm),
                            Text(
                              '$totalDuration minutos',
                              style: AppTextStyles.labelLg,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  AppButton(
                    text: 'Confirmar Reserva',
                    onPressed: () => _submit(barbershop.id),
                    isLoading: appointmentsAsync.isLoading,
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
