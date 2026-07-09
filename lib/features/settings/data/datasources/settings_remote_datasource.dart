import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../models/barbershop_model.dart';
import '../models/barbershop_hours_model.dart';

abstract class SettingsRemoteDataSource {
  Future<BarbershopModel> getBarbershop(String id);
  Future<BarbershopModel> updateBarbershop(BarbershopModel barbershop);
  Future<List<BarbershopHoursModel>> getBarbershopHours(String barbershopId);
  Future<List<BarbershopHoursModel>> updateBarbershopHours(List<BarbershopHoursModel> hours);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final sb.SupabaseClient supabase;

  SettingsRemoteDataSourceImpl({required this.supabase});

  @override
  Future<BarbershopModel> getBarbershop(String id) async {
    try {
      final data = await supabase
          .from(DbTables.barbershops)
          .select()
          .eq('id', id)
          .single();

      return BarbershopModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al obtener la barbería: $e');
    }
  }

  @override
  Future<BarbershopModel> updateBarbershop(BarbershopModel barbershop) async {
    try {
      final data = await supabase
          .from(DbTables.barbershops)
          .update(barbershop.toJson())
          .eq('id', barbershop.id)
          .select()
          .single();

      return BarbershopModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar la barbería: $e');
    }
  }

  @override
  Future<List<BarbershopHoursModel>> getBarbershopHours(String barbershopId) async {
    try {
      final List<dynamic> data = await supabase
          .from(DbTables.barbershopHours)
          .select()
          .eq('barbershop_id', barbershopId)
          .order('day_of_week', ascending: true);

      // Si no existen horarios creados aún en base de datos, inicializamos por defecto
      if (data.isEmpty) {
        return await _initializeDefaultHours(barbershopId);
      }

      return data.map((item) => BarbershopHoursModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener horarios de la barbería: $e');
    }
  }

  @override
  Future<List<BarbershopHoursModel>> updateBarbershopHours(
    List<BarbershopHoursModel> hours,
  ) async {
    try {
      final List<Map<String, dynamic>> upsertData =
          hours.map((h) => h.toJson()).toList();

      final List<dynamic> data = await supabase
          .from(DbTables.barbershopHours)
          .upsert(upsertData)
          .select()
          .order('day_of_week', ascending: true);

      return data.map((item) => BarbershopHoursModel.fromJson(item)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al actualizar horarios de la barbería: $e');
    }
  }

  /// Helper to initialize default operating hours (Monday to Sunday, 09:00 - 18:00)
  Future<List<BarbershopHoursModel>> _initializeDefaultHours(String barbershopId) async {
    final List<Map<String, dynamic>> defaultList = [];
    for (int i = 0; i <= 6; i++) {
      // 0 = Domingo, 1 = Lunes, etc.
      // Sábado y Domingo por defecto se pueden dejar cerrados o abiertos
      final bool openByDefault = i != 0; // Cerrado los domingos por defecto
      defaultList.add({
        'barbershop_id': barbershopId,
        'day_of_week': i,
        'open_time': '09:00:00',
        'close_time': '18:00:00',
        'is_open': openByDefault,
      });
    }

    final List<dynamic> inserted = await supabase
        .from(DbTables.barbershopHours)
        .insert(defaultList)
        .select()
        .order('day_of_week', ascending: true);

    return inserted.map((item) => BarbershopHoursModel.fromJson(item)).toList();
  }
}
