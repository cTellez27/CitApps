import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/entities/commission_report_entity.dart';
import '../../domain/usecases/get_clients_usecase.dart';
import '../../domain/usecases/create_client_usecase.dart';
import '../../domain/usecases/update_client_usecase.dart';
import '../../domain/usecases/get_commissions_report_usecase.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/repositories/client_repository.dart';

// ── Dependency Injection Providers ──

final clientRemoteDataSourceProvider = Provider<ClientRemoteDataSource>((ref) {
  return ClientRemoteDataSourceImpl(supabase: ref.watch(supabaseClientProvider));
});

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(remoteDataSource: ref.watch(clientRemoteDataSourceProvider));
});

final getClientsUseCaseProvider = Provider<GetClientsUseCase>((ref) {
  return GetClientsUseCase(ref.watch(clientRepositoryProvider));
});

final createClientUseCaseProvider = Provider<CreateClientUseCase>((ref) {
  return CreateClientUseCase(ref.watch(clientRepositoryProvider));
});

final updateClientUseCaseProvider = Provider<UpdateClientUseCase>((ref) {
  return UpdateClientUseCase(ref.watch(clientRepositoryProvider));
});

final getCommissionsReportUseCaseProvider = Provider<GetCommissionsReportUseCase>((ref) {
  return GetCommissionsReportUseCase(ref.watch(clientRepositoryProvider));
});

// ── Notifier Providers ──

final clientsStateProvider =
    AsyncNotifierProvider<ClientsNotifier, List<ClientEntity>>(() {
  return ClientsNotifier();
});

class ClientsNotifier extends AsyncNotifier<List<ClientEntity>> {
  @override
  Future<List<ClientEntity>> build() async {
    final barbershopId = ref.watch(activeBarbershopIdProvider);
    if (barbershopId == null) return [];

    final result = await ref.read(getClientsUseCaseProvider).execute(barbershopId);
    return result.fold(
      (failure) => throw failure,
      (clients) => clients,
    );
  }

  Future<void> addClient(ClientEntity client) async {
    state = const AsyncValue.loading();
    final result = await ref.read(createClientUseCaseProvider).execute(client);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(), // Refresh list
    );
  }

  Future<void> updateClientDetails(ClientEntity client) async {
    state = const AsyncValue.loading();
    final result = await ref.read(updateClientUseCaseProvider).execute(client);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}

// ── Reports Query Structure ──

class CommissionReportQuery {
  final String employeeId;
  final String employeeName;
  final double commissionRate;
  final DateTime startDate;
  final DateTime endDate;

  const CommissionReportQuery({
    required this.employeeId,
    required this.employeeName,
    required this.commissionRate,
    required this.startDate,
    required this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommissionReportQuery &&
          runtimeType == other.runtimeType &&
          employeeId == other.employeeId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => employeeId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

final commissionsReportProvider =
    FutureProvider.family<CommissionReportEntity, CommissionReportQuery>((ref, query) async {
  final result = await ref.read(getCommissionsReportUseCaseProvider).execute(
        employeeId: query.employeeId,
        employeeName: query.employeeName,
        commissionRate: query.commissionRate,
        startDate: query.startDate,
        endDate: query.endDate,
      );

  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
});
