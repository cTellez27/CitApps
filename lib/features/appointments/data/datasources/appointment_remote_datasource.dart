import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../models/appointment_model.dart';
import '../models/appointment_service_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments(String barbershopId, DateTime date);
  Future<AppointmentModel> createAppointment(
    AppointmentModel appointment,
    List<AppointmentServiceModel> services,
  );
  Future<void> updateAppointmentStatus(String id, String status);
  Future<List<AppointmentModel>> getEmployeeAppointments(String employeeId, DateTime date);
  Future<List<AppointmentServiceModel>> getAppointmentServices(String appointmentId);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final sb.SupabaseClient supabase;

  AppointmentRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<AppointmentModel>> getAppointments(String barbershopId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc().toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc().toIso8601String();

      final List<dynamic> data = await supabase
          .from(DbTables.appointments)
          .select()
          .eq('barbershop_id', barbershopId)
          .gte('start_time', startOfDay)
          .lte('start_time', endOfDay)
          .order('start_time', ascending: true);

      return data.map((item) => AppointmentModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener citas de la barbería: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(
    AppointmentModel appointment,
    List<AppointmentServiceModel> services,
  ) async {
    try {
      // 1. Validar solapamiento en el backend antes de insertar
      final startStr = appointment.startTime.toUtc().toIso8601String();
      final endStr = appointment.endTime.toUtc().toIso8601String();

      final List<dynamic> overlapping = await supabase
          .from(DbTables.appointments)
          .select()
          .eq('employee_id', appointment.employeeId)
          .neq('status', 'cancelled')
          .lt('start_time', endStr)
          .gt('end_time', startStr);

      if (overlapping.isNotEmpty) {
        throw const ServerException(
          message: 'Error: El barbero ya tiene una cita agendada en este horario.',
        );
      }

      // 2. Insertar cita
      final insertedAppointmentData = await supabase
          .from(DbTables.appointments)
          .insert(appointment.toJson())
          .select()
          .single();

      final createdAppointment = AppointmentModel.fromJson(insertedAppointmentData);

      // 3. Insertar servicios asociados a la cita
      if (services.isNotEmpty) {
        final List<Map<String, dynamic>> insertServicesList = services
            .map((s) => AppointmentServiceModel(
                  appointmentId: createdAppointment.id,
                  serviceId: s.serviceId,
                  price: s.price,
                ).toJson())
            .toList();

        await supabase.from(DbTables.appointmentServices).insert(insertServicesList);
      }

      return createdAppointment;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Error al registrar la cita: $e');
    }
  }

  @override
  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      await supabase
          .from(DbTables.appointments)
          .update({'status': status})
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el estado de la cita: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getEmployeeAppointments(String employeeId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0).toUtc().toIso8601String();
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).toUtc().toIso8601String();

      final List<dynamic> data = await supabase
          .from(DbTables.appointments)
          .select()
          .eq('employee_id', employeeId)
          .neq('status', 'cancelled')
          .gte('start_time', startOfDay)
          .lte('start_time', endOfDay)
          .order('start_time', ascending: true);

      return data.map((item) => AppointmentModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener citas del empleado: $e');
    }
  }

  @override
  Future<List<AppointmentServiceModel>> getAppointmentServices(String appointmentId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.appointmentServices)
          .select()
          .eq('appointment_id', appointmentId);

      return data.map((item) => AppointmentServiceModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener servicios de la cita: $e');
    }
  }
}
