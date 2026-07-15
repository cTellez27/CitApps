import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entity.dart';
import '../entities/appointment_service_entity.dart';
import '../entities/appointment_product_entity.dart';

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

  // Extras
  Future<Either<Failure, void>> addExtraService(String appointmentId, String serviceId, double price);
  Future<Either<Failure, void>> addExtraProduct(String appointmentId, String productId, double price, int quantity);
  Future<Either<Failure, List<AppointmentProductEntity>>> getAppointmentProducts(String appointmentId);
  Future<Either<Failure, void>> updateAppointmentTotalPrice(String appointmentId, double totalPrice);
  Future<Either<Failure, void>> deleteExtraService(String appointmentId, String serviceId);
  Future<Either<Failure, void>> deleteExtraProduct(String appointmentId, String productId);
  Future<Either<Failure, void>> deleteAppointment(String id);
  Future<Either<Failure, void>> deleteAppointments(List<String> ids);
}

