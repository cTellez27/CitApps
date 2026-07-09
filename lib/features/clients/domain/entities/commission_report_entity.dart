import 'package:equatable/equatable.dart';

/// Domain entity representing a calculated commission summary for an employee in a date range.
class CommissionReportEntity extends Equatable {
  final String employeeId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalGenerated;
  final double totalCommission;
  final int appointmentsCount;

  const CommissionReportEntity({
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.totalGenerated,
    required this.totalCommission,
    required this.appointmentsCount,
  });

  @override
  List<Object?> get props => [
        employeeId,
        employeeName,
        startDate,
        endDate,
        totalGenerated,
        totalCommission,
        appointmentsCount,
      ];
}
