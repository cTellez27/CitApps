import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/services_provider.dart';
import '../../domain/entities/service_entity.dart';

class ServiceListPage extends ConsumerStatefulWidget {
  const ServiceListPage({super.key});

  @override
  ConsumerState<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends ConsumerState<ServiceListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showInactive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceEntity> _filterServices(List<ServiceEntity> list) {
    return list.where((svc) {
      final matchesSearch = svc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (svc.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesStatus = _showInactive || svc.isActive;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(servicesStateProvider);
    final authState = ref.watch(authNotifierProvider);

    final isOwnerOrAdmin = authState is Authenticated &&
        (authState.user.role == UserRole.owner || authState.user.role == UserRole.admin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Servicios'),
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
                  label: 'Buscar servicio',
                  controller: _searchController,
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ],
            ),
          ),

          // Services List
          Expanded(
            child: servicesAsync.when(
              data: (list) {
                final filteredList = _filterServices(list);

                if (filteredList.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.design_services_outlined,
                    title: 'No se encontraron servicios',
                    subtitle: 'Intenta ajustar los filtros de búsqueda.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final svc = filteredList[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cardDark,
                          child: const Icon(Icons.content_cut_rounded, color: AppColors.primary),
                        ),
                        title: Text(
                          svc.name,
                          style: AppTextStyles.labelLg.copyWith(
                            color: svc.isActive ? null : AppColors.textSecondaryDark,
                            decoration: svc.isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          '${svc.durationMinutes} min • ${CurrencyUtils.format(svc.price)}',
                          style: AppTextStyles.bodySm,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!svc.isActive)
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
                        onTap: () => context.push('${RouteNames.services}/${svc.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(servicesStateProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isOwnerOrAdmin
          ? FloatingActionButton(
              onPressed: () => context.push(RouteNames.serviceNew),
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
