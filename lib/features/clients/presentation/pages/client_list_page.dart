import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/clients_provider.dart';
import '../../domain/entities/client_entity.dart';

class ClientListPage extends ConsumerStatefulWidget {
  const ClientListPage({super.key});

  @override
  ConsumerState<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends ConsumerState<ClientListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ClientEntity> _filterClients(List<ClientEntity> list) {
    return list.where((client) {
      final query = _searchQuery.toLowerCase();
      final matchesName = client.fullName.toLowerCase().contains(query);
      final matchesPhone = client.phone?.contains(_searchQuery) ?? false;
      final matchesEmail = client.email?.toLowerCase().contains(query) ?? false;

      return matchesName || matchesPhone || matchesEmail;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Clientes'),
      ),
      body: Column(
        children: [
          // Search Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: AppTextField(
              label: 'Buscar cliente',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Clients List
          Expanded(
            child: clientsAsync.when(
              data: (list) {
                final filteredList = _filterClients(list);

                if (filteredList.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline_rounded,
                    title: 'No se encontraron clientes',
                    subtitle: 'Intenta registrar un cliente nuevo o ajustar la búsqueda.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final client = filteredList[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cardDark,
                          child: Text(
                            client.fullName[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                        title: Text(
                          client.fullName,
                          style: AppTextStyles.labelLg,
                        ),
                        subtitle: Text(
                          '${client.phone ?? 'Sin teléfono'} • ${client.email ?? 'Sin correo'}',
                          style: AppTextStyles.bodySm,
                        ),
                        trailing: const Icon(Icons.edit_outlined, size: 18),
                        onTap: () => context.push('/clients/${client.id}/edit'),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(clientsStateProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteNames.clientNew),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
