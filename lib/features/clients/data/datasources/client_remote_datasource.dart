import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../models/client_model.dart';

abstract class ClientRemoteDataSource {
  Future<List<ClientModel>> getClients(String barbershopId);
  Future<ClientModel> createClient(ClientModel client);
  Future<ClientModel> updateClient(ClientModel client);
  Future<List<Map<String, dynamic>>> getCompletedAppointmentsRaw({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final sb.SupabaseClient supabase;

  ClientRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<ClientModel>> getClients(String barbershopId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.clients)
          .select()
          .eq('barbershop_id', barbershopId)
          .order('full_name', ascending: true);

      return data.map((item) => ClientModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener directorio de clientes: $e');
    }
  }

  @override
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final data = await supabase
          .from(DbTables.clients)
          .insert(client.toJson())
          .select()
          .single();

      return ClientModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al registrar cliente: $e');
    }
  }

  @override
  Future<ClientModel> updateClient(ClientModel client) async {
    try {
      final data = await supabase
          .from(DbTables.clients)
          .update(client.toJson())
          .eq('id', client.id)
          .select()
          .single();

      return ClientModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar datos del cliente: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCompletedAppointmentsRaw({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startIso = startDate.toUtc().toIso8601String();
      final endIso = endDate.toUtc().toIso8601String();

      final List<dynamic> data = await supabase
          .from(DbTables.appointments)
          .select('total_price')
          .eq('employee_id', employeeId)
          .eq('status', 'completed')
          .gte('start_time', startIso)
          .lte('start_time', endIso);

      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw ServerException(message: 'Error al cargar citas completadas para reportes: $e');
    }
  }
}
