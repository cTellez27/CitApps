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
import '../../../auth/domain/entities/user_entity.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/employees_provider.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeFormPage extends ConsumerStatefulWidget {
  final String? employeeId;

  const EmployeeFormPage({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends ConsumerState<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _commissionController = TextEditingController();
  UserRole _role = UserRole.barber;
  bool _isActive = true;
  EmployeeEntity? _existingEmployee;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  void _initFields(List<EmployeeEntity> employees) {
    if (!_isInitialized && widget.employeeId != null) {
      _existingEmployee = employees.firstWhere((e) => e.id == widget.employeeId);
      _nameController.text = _existingEmployee!.fullName;
      _phoneController.text = _existingEmployee!.phone ?? '';
      _emailController.text = _existingEmployee!.email ?? '';
      _commissionController.text = _existingEmployee!.commissionRate.toString();
      _role = _existingEmployee!.role;
      _isActive = _existingEmployee!.isActive;
      _isInitialized = true;
    }
  }

  void _submit(String barbershopId) {
    if (_formKey.currentState!.validate()) {
      final double commission = double.tryParse(_commissionController.text) ?? 0.0;

      if (widget.employeeId == null) {
        final newEmployee = EmployeeEntity(
          id: const Uuid().v4(),
          barbershopId: barbershopId,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          role: _role,
          commissionRate: commission,
          isActive: _isActive,
        );
        ref.read(employeesStateProvider.notifier).addEmployee(newEmployee).then((_) {
          if (!mounted) return;
          context.pop();
        });
      } else {
        final updated = _existingEmployee!.copyWith(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          role: _role,
          commissionRate: commission,
          isActive: _isActive,
        );
        ref.read(employeesStateProvider.notifier).updateEmployeeDetails(updated).then((_) {
          if (!mounted) return;
          context.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employeeId == null ? 'Nuevo Empleado' : 'Editar Empleado'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('Error: No se encontró contexto de la barbería.'));
          }

          // Initialize fields if editing
          employeesAsync.whenData((list) => _initFields(list));

          final showCommissions = barbershop.enableCommissions;

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
                        Text('Información de Perfil', style: AppTextStyles.h3),
                        const SizedBox(height: AppSizes.lg),

                        // Full Name
                        AppTextField(
                          label: AppStrings.fullName,
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) => Validators.required(val, 'El nombre completo'),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Phone
                        AppTextField(
                          label: AppStrings.phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: Validators.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Email
                        AppTextField(
                          label: AppStrings.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: Validators.email,
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
                        Text('Rol & Ajustes del Negocio', style: AppTextStyles.h4),
                        const SizedBox(height: AppSizes.lg),

                        // Role Selector
                        DropdownButtonFormField<UserRole>(
                          initialValue: _role,
                          decoration: const InputDecoration(
                            labelText: 'Rol del Empleado',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: UserRole.values.map((role) {
                            final label = switch (role) {
                              UserRole.owner => AppStrings.owner,
                              UserRole.admin => AppStrings.admin,
                              UserRole.barber => AppStrings.barber,
                              UserRole.receptionist => AppStrings.receptionist,
                            };
                            return DropdownMenuItem(
                              value: role,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _role = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.md),

                        // Commission (only if enabled globally)
                        if (showCommissions) ...[
                          AppTextField(
                            label: 'Porcentaje de Comisión (%)',
                            controller: _commissionController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.percent_rounded,
                            validator: (val) {
                              final numCheck = Validators.nonNegativeNumber(val, 'La comisión');
                              if (numCheck != null) return numCheck;
                              final parsed = double.tryParse(val!) ?? 0.0;
                              if (parsed > 100.0) {
                                return 'La comisión no puede exceder el 100%';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.md),
                        ],

                        // Status toggle
                        if (widget.employeeId != null) ...[
                          SwitchListTile(
                            title: const Text('Empleado Activo'),
                            subtitle: const Text('Si se desactiva, no podrá acceder a la agenda.'),
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
                    isLoading: employeesAsync.isLoading,
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
