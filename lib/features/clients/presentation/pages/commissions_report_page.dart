import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../employees/presentation/providers/employees_provider.dart';
import '../../../employees/domain/entities/employee_entity.dart';
import '../providers/clients_provider.dart';

class CommissionsReportPage extends ConsumerStatefulWidget {
  const CommissionsReportPage({super.key});

  @override
  ConsumerState<CommissionsReportPage> createState() => _CommissionsReportPageState();
}

class _CommissionsReportPageState extends ConsumerState<CommissionsReportPage> {
  EmployeeEntity? _selectedEmployee;
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  void _selectRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      helpText: 'Periodo del Reporte',
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final barbershopAsync = ref.watch(barbershopStateProvider);
    final employeesAsync = ref.watch(employeesStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comisiones y Ganancias'),
      ),
      body: barbershopAsync.when(
        data: (barbershop) {
          if (barbershop == null) {
            return const Center(child: Text('Error: No se encontró contexto de la barbería.'));
          }

          // If commissions module is disabled globally, show disabled placeholder
          if (!barbershop.enableCommissions) {
            return const Padding(
              padding: EdgeInsets.all(AppSizes.xl),
              child: EmptyStateWidget(
                icon: Icons.monetization_on_outlined,
                title: 'Comisiones Desactivadas',
                subtitle: 'Habilita el módulo de comisiones en los Ajustes de la barbería para activar este reporte.',
              ),
            );
          }

          return Column(
            children: [
              // 1. Selector bar: Employee + Date Range
              Container(
                color: AppColors.cardDark,
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Employee Dropdown
                    employeesAsync.when(
                      data: (employees) {
                        final activeEmployees = employees.where((e) => e.isActive).toList();

                        return DropdownButtonFormField<EmployeeEntity>(
                          initialValue: _selectedEmployee,
                          decoration: const InputDecoration(
                            labelText: 'Selecciona Barbero',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: activeEmployees.map((emp) {
                            return DropdownMenuItem(
                              value: emp,
                              child: Text(emp.fullName),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedEmployee = val;
                            });
                          },
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Date range picker trigger
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Periodo: ${DateFormat('d/MM/yy').format(_selectedRange.start)} al ${DateFormat('d/MM/yy').format(_selectedRange.end)}',
                            style: AppTextStyles.labelMd,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _selectRange,
                          icon: const Icon(Icons.date_range_rounded, size: 16),
                          label: const Text('Elegir Rango'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Report summary details
              Expanded(
                child: _selectedEmployee == null
                    ? const EmptyStateWidget(
                        icon: Icons.analytics_outlined,
                        title: 'Selecciona un barbero',
                        subtitle: 'Elige un barbero de la lista superior para generar su reporte financiero.',
                      )
                    : ref
                        .watch(
                          commissionsReportProvider(
                            CommissionReportQuery(
                              employeeId: _selectedEmployee!.id,
                              employeeName: _selectedEmployee!.fullName,
                              commissionRate: _selectedEmployee!.commissionRate,
                              startDate: _selectedRange.start,
                              endDate: _selectedRange.end,
                            ),
                          ),
                        )
                        .when(
                          data: (report) {
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(AppSizes.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Metric Card 1: Total Commission
                                  AppCard(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Comisión Devengada (${_selectedEmployee!.commissionRate}%)',
                                          style: AppTextStyles.bodySm,
                                        ),
                                        const SizedBox(height: AppSizes.xs),
                                        Text(
                                          CurrencyUtils.format(report.totalCommission),
                                          style: AppTextStyles.h1.copyWith(color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.md),

                                  // Metric Card 2: Details breakdown
                                  AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text('Resumen Financiero', style: AppTextStyles.h4),
                                        const SizedBox(height: AppSizes.md),
                                        ListTile(
                                          title: const Text('Total Facturado Brutal'),
                                          trailing: Text(
                                            CurrencyUtils.format(report.totalGenerated),
                                            style: AppTextStyles.labelLg,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        const Divider(),
                                        ListTile(
                                          title: const Text('Citas Completadas'),
                                          trailing: Text(
                                            '${report.appointmentsCount} citas',
                                            style: AppTextStyles.labelLg,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const LoadingWidget(),
                          error: (e, _) => AppErrorWidget(message: e.toString()),
                        ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
      ),
    );
  }
}
