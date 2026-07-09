import 'package:equatable/equatable.dart';

import 'services_report_item_entity.dart';

/// Aggregated services report for a given period.
class ServicesReportEntity extends Equatable {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalAppointments;
  final double totalRevenue;
  final List<ServicesReportItemEntity> items; // sorted by count desc

  const ServicesReportEntity({
    required this.periodStart,
    required this.periodEnd,
    required this.totalAppointments,
    required this.totalRevenue,
    required this.items,
  });

  double get averageTicket =>
      totalAppointments == 0 ? 0 : totalRevenue / totalAppointments;

  @override
  List<Object?> get props =>
      [periodStart, periodEnd, totalAppointments, totalRevenue, items];
}
