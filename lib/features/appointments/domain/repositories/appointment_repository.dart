import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../entities/appointment_service_entity.dart';

/// Contract definition for Appointments repository.
///
/// Manages bookings, slot validations, and cancellations.
abstract class AppointmentRepository {
  /// Fetches appointments for a barbershop on a specific date.
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(
    String barbershopId,
    DateTime date,
  );

  /// Creates a new booking reservation with assigned services.
  Future<Either<Failure, AppointmentEntity>> createAppointment(
    AppointmentEntity appointment,
    List<AppointmentServiceEntity> services,
  );

  /// Updates status of an appointment (e.g. completed, cancelled).
  Future<Either<Failure, void>> updateAppointmentStatus(String id, String status);

  /// Fetches appointments for a single employee on a specific date.
  Future<Either<Failure, List<AppointmentEntity>>> getEmployeeAppointments(
    String employeeId,
    DateTime date,
  );

  /// Fetches services list associated with an appointment.
  Future<Either<Failure, List<AppointmentServiceEntity>>> getAppointmentServices(
    String appointmentId,
  );
}
