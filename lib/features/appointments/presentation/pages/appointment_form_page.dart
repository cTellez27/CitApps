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
      firstDate: DateTime.now().subtract(const Duration(days: 0)), // Today onwards
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Fecha de Reserva',
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null; // Reset slot
      });
    }
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
      final totalDuration = _selectedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes);
      final totalPrice = _selectedServices.fold<double>(0.0, (sum, s) => sum + s.price);
      final appointmentId = const Uuid().v4();

      final appointment = AppointmentEntity(
        id: appointmentId,
        barbershopId: barbershopId,
        employeeId: _selectedEmployeeId!,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        customerEmail: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        startTime: _selectedSlot!,
        endTime: _selectedSlot!.add(Duration(minutes: totalDuration)),
        totalPrice: totalPrice,
        status: 'pending',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);
    final servicesAsync = ref.watch(servicesStateProvider);
    final appointmentsAsync = ref.watch(appointmentsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Cita'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('Error: No se encontró contexto de la barbería.'));
          }

          // Total accumulator calculations
          final totalDuration = _selectedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes);
          final totalPrice = _selectedServices.fold<double>(0.0, (sum, s) => sum + s.price);

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
                      final activeBarbers = employees.where((e) => e.isActive).toList();
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
                                  _selectedSlot = null; // reset slot
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
                      final activeServices = services.where((s) => s.isActive).toList();
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
                                    _selectedSlot = null; // recalculate hours
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
                              DateFormat('EEEE, d \'de\' MMMM', 'es').format(_selectedDate),
                              style: AppTextStyles.labelLg,
                            ),
                            TextButton.icon(
                              onPressed: () => _selectDate(context),
                              icon: const Icon(Icons.calendar_today_rounded, size: 16),
                              label: const Text('Elegir Día'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // 4. Selección de Horas Libres (disponibilidad)
                  if (_selectedEmployeeId != null && _selectedServices.isNotEmpty) ...[
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
                                  Text('4. Horarios Disponibles', style: AppTextStyles.h4),
                                  const SizedBox(height: AppSizes.md),
                                  if (slots.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                                      child: Text(
                                        'No hay turnos disponibles para este día.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.error),
                                      ),
                                    )
                                  else
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: AppSizes.sm,
                                        mainAxisSpacing: AppSizes.sm,
                                        childAspectRatio: 2.1,
                                      ),
                                      itemCount: slots.length,
                                      itemBuilder: (context, index) {
                                        final slot = slots[index];
                                        final isSelected = _selectedSlot == slot;

                                        return ChoiceChip(
                                          label: Text(
                                            DateFormat('HH:mm').format(slot),
                                            style: TextStyle(
                                              color: isSelected ? Colors.black : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedSlot = selected ? slot : null;
                                            });
                                          },
                                        );
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
                  ],

                  // 5. Detalles del Cliente
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('5. Datos de Contacto', style: AppTextStyles.h4),
                        const SizedBox(height: AppSizes.lg),

                        // Customer Name
                        AppTextField(
                          label: 'Nombre del Cliente',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) => Validators.required(val, 'El nombre del cliente'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Phone
                        AppTextField(
                          label: 'Teléfono',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Email
                        AppTextField(
                          label: 'Correo Electrónico (Opcional)',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Notes
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
                              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Duración Estimada:', style: AppTextStyles.bodySm),
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
