import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../models/service_model.dart';

abstract class ServiceRemoteDataSource {
  Future<List<ServiceModel>> getServices(String barbershopId);
  Future<ServiceModel> createService(ServiceModel service);
  Future<ServiceModel> updateService(ServiceModel service);
  Future<void> deleteService(String id);
  Future<List<String>> getServiceEmployees(String serviceId);
  Future<void> updateServiceEmployees(String serviceId, List<String> employeeIds);
}

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final sb.SupabaseClient supabase;

  ServiceRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<ServiceModel>> getServices(String barbershopId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.services)
          .select()
          .eq('barbershop_id', barbershopId)
          .order('name', ascending: true);

      return data.map((item) => ServiceModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener servicios: $e');
    }
  }

  @override
  Future<ServiceModel> createService(ServiceModel service) async {
    try {
      final data = await supabase
          .from(DbTables.services)
          .insert(service.toJson())
          .select()
          .single();

      return ServiceModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al registrar el servicio: $e');
    }
  }

  @override
  Future<ServiceModel> updateService(ServiceModel service) async {
    try {
      final data = await supabase
          .from(DbTables.services)
          .update(service.toJson())
          .eq('id', service.id)
          .select()
          .single();

      return ServiceModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar el servicio: $e');
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await supabase
          .from(DbTables.services)
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al desactivar el servicio: $e');
    }
  }

  @override
  Future<List<String>> getServiceEmployees(String serviceId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.employeeServices)
          .select('employee_id')
          .eq('service_id', serviceId);

      return data.map((item) => item['employee_id'] as String).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener asignaciones del servicio: $e');
    }
  }

  @override
  Future<void> updateServiceEmployees(String serviceId, List<String> employeeIds) async {
    try {
      // 1. Eliminar asociaciones existentes para el servicio
      await supabase
          .from(DbTables.employeeServices)
          .delete()
          .eq('service_id', serviceId);

      // 2. Insertar nuevas asociaciones
      if (employeeIds.isNotEmpty) {
        final List<Map<String, dynamic>> insertList = employeeIds
            .map((empId) => {
                  'service_id': serviceId,
                  'employee_id': empId,
                })
            .toList();

        await supabase.from(DbTables.employeeServices).insert(insertList);
      }
    } catch (e) {
      throw ServerException(message: 'Error al actualizar asignaciones del servicio: $e');
    }
  }
}
