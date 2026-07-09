import 'package:equatable/equatable.dart';

/// One row in the services report — a single service with aggregated stats.
class ServicesReportItemEntity extends Equatable {
  final String serviceName;
  final int count;        // How many times performed in the period
  final double revenue;   // Total income from this service

  const ServicesReportItemEntity({
    required this.serviceName,
    required this.count,
    required this.revenue,
  });

  @override
  List<Object?> get props => [serviceName, count, revenue];
}
