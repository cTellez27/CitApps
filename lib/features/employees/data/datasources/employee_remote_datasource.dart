import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../models/employee_model.dart';
import '../models/employee_schedule_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees(String barbershopId);
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String id);
  Future<List<EmployeeScheduleModel>> getEmployeeSchedule(String employeeId);
  Future<List<EmployeeScheduleModel>> updateEmployeeSchedule(List<EmployeeScheduleModel> schedules);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final sb.SupabaseClient supabase;

  EmployeeRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<EmployeeModel>> getEmployees(String barbershopId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.employees)
          .select()
          .eq('barbershop_id', barbershopId)
          .order('full_name', ascending: true);

      return data.map((item) => EmployeeModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener empleados: $e');
    }
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      final data = await supabase
          .from(DbTables.employees)
          .insert(employee.toJson())
          .select()
          .single();

      return EmployeeModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al registrar el empleado: $e');
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(EmployeeModel employee) async {
    try {
      final data = await supabase
          .from(DbTables.employees)
          .update(employee.toJson())
          .eq('id', employee.id)
          .select()
          .single();

      return EmployeeModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el empleado: $e');
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await supabase
          .from(DbTables.employees)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al desactivar el empleado: $e');
    }
  }

  @override
  Future<List<EmployeeScheduleModel>> getEmployeeSchedule(String employeeId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.employeeSchedules)
          .select()
          .eq('employee_id', employeeId)
          .order('day_of_week', ascending: true);

      // Si no hay horario establecido, retornamos lista vacía.
      // La UI se encargará de inicializarlo con base al horario general de la barbería.
      return data.map((item) => EmployeeScheduleModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener horario del empleado: $e');
    }
  }

  @override
  Future<List<EmployeeScheduleModel>> updateEmployeeSchedule(
    List<EmployeeScheduleModel> schedules,
  ) async {
    try {
      final List<Map<String, dynamic>> upsertData =
          schedules.map((s) => s.toJson()).toList();

      final List<dynamic> data = await supabase
          .from(DbTables.employeeSchedules)
          .upsert(upsertData)
          .select()
          .order('day_of_week', ascending: true);

      return data.map((item) => EmployeeScheduleModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al guardar horario del empleado: $e');
    }
  }
}
