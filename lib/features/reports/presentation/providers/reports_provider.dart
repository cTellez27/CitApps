import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../domain/entities/services_report_entity.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/usecases/get_services_report_usecase.dart';
import '../../data/datasources/reports_remote_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';

// ── Period selection enum ──

enum ReportPeriod { currentWeek, currentMonth, lastMonth }

// ── DI Providers ──

final reportsRemoteDataSourceProvider = Provider<ReportsRemoteDataSource>((ref) {
  return ReportsRemoteDataSourceImpl(
      supabase: ref.watch(supabaseClientProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(
      remoteDataSource: ref.watch(reportsRemoteDataSourceProvider));
});

final getServicesReportUseCaseProvider = Provider<GetServicesReportUseCase>((ref) {
  return GetServicesReportUseCase(ref.watch(reportsRepositoryProvider));
});

// ── Period state ──

final reportPeriodProvider = StateProvider<ReportPeriod>(
  (_) => ReportPeriod.currentMonth,
);

// ── Report query model ──

class ServicesReportQuery {
  final String barbershopId;
  final ReportPeriod period;

  const ServicesReportQuery(
      {required this.barbershopId, required this.period});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicesReportQuery &&
          barbershopId == other.barbershopId &&
          period == other.period;

  @override
  int get hashCode => barbershopId.hashCode ^ period.hashCode;
}

// ── Helper: compute date range for period ──

(DateTime, DateTime) periodDateRange(ReportPeriod period) {
  final now = DateTime.now();
  switch (period) {
    case ReportPeriod.currentWeek:
      // Monday of current week to Sunday
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(monday.year, monday.month, monday.day);
      final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
      return (start, end);
    case ReportPeriod.currentMonth:
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return (start, end);
    case ReportPeriod.lastMonth:
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastYear = now.month == 1 ? now.year - 1 : now.year;
      final start = DateTime(lastYear, lastMonth, 1);
      final end = DateTime(lastYear, lastMonth + 1, 0, 23, 59, 59);
      return (start, end);
  }
}

// ── Main report provider ──

final servicesReportProvider =
    FutureProvider.family<ServicesReportEntity, ServicesReportQuery>(
        (ref, query) async {
  final (start, end) = periodDateRange(query.period);
  final result = await ref.read(getServicesReportUseCaseProvider).execute(
        barbershopId: query.barbershopId,
        startDate: start,
        endDate: end,
      );
  return result.fold(
    (failure) => throw failure,
    (report) => report,
  );
});
