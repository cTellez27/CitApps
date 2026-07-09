import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/employees_provider.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeListPage extends ConsumerStatefulWidget {
  const EmployeeListPage({super.key});

  @override
  ConsumerState<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends ConsumerState<EmployeeListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _roleFilter;
  bool _showInactive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmployeeEntity> _filterEmployees(List<EmployeeEntity> list) {
    return list.where((emp) {
      final matchesSearch = emp.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (emp.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (emp.phone?.contains(_searchQuery) ?? false);

      final matchesRole = _roleFilter == null || emp.role == _roleFilter;
      final matchesStatus = _showInactive || emp.isActive;

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStateProvider);
    final authState = ref.watch(authNotifierProvider);

    final isOwnerOrAdmin = authState is Authenticated &&
        (authState.user.role == UserRole.owner || authState.user.role == UserRole.admin);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.employees),
        actions: [
          IconButton(
            icon: Icon(
              _showInactive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: _showInactive ? AppColors.primary : null,
            ),
            tooltip: _showInactive ? 'Ocultar inactivos' : 'Mostrar inactivos',
            onPressed: () {
              setState(() {
                _showInactive = !_showInactive;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              children: [
                AppTextField(
                  label: 'Buscar empleado',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: AppSizes.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSizes.xs),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: _roleFilter == null,
                          onSelected: (selected) {
                            if (selected) setState(() => _roleFilter = null);
                          },
                        ),
                      ),
                      ...UserRole.values.map((role) {
                        final label = switch (role) {
                          UserRole.owner => AppStrings.owner,
                          UserRole.admin => AppStrings.admin,
                          UserRole.barber => AppStrings.barber,
                          UserRole.receptionist => AppStrings.receptionist,
                        };
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSizes.xs),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _roleFilter == role,
                            onSelected: (selected) {
                              setState(() {
                                _roleFilter = selected ? role : null;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Employees List
          Expanded(
            child: employeesAsync.when(
              data: (list) {
                final filteredList = _filterEmployees(list);

                if (filteredList.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'No se encontraron empleados',
                    subtitle: 'Intenta ajustar los filtros de búsqueda.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final emp = filteredList[index];
                    final roleLabel = switch (emp.role) {
                      UserRole.owner => AppStrings.owner,
                      UserRole.admin => AppStrings.admin,
                      UserRole.barber => AppStrings.barber,
                      UserRole.receptionist => AppStrings.receptionist,
                    };

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cardDark,
                          child: Text(
                            emp.fullName[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(
                          emp.fullName,
                          style: AppTextStyles.labelLg.copyWith(
                            color: emp.isActive ? null : AppColors.textSecondaryDark,
                            decoration: emp.isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          '$roleLabel • ${emp.phone ?? 'Sin teléfono'}',
                          style: AppTextStyles.bodySm,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!emp.isActive)
                              const Padding(
                                padding: EdgeInsets.only(right: AppSizes.sm),
                                child: Chip(
                                  label: Text('Inactivo', style: TextStyle(fontSize: 10)),
                                  backgroundColor: AppColors.error,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                        onTap: () => context.push('${RouteNames.employees}/${emp.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(employeesStateProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isOwnerOrAdmin
          ? FloatingActionButton(
              onPressed: () => context.push(RouteNames.employeeNew),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
