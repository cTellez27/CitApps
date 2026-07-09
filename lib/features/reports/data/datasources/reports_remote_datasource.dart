import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/db_tables.dart';
import '../../domain/entities/services_report_entity.dart';
import '../../domain/entities/services_report_item_entity.dart';

abstract class ReportsRemoteDataSource {
  Future<ServicesReportEntity> getServicesReport({
    required String barbershopId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final sb.SupabaseClient supabase;

  ReportsRemoteDataSourceImpl({required this.supabase});

  @override
  Future<ServicesReportEntity> getServicesReport({
    required String barbershopId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toUtc().toIso8601String();
      final endStr = endDate.toUtc().toIso8601String();

      // 1. Fetch completed appointments in range
      final List<dynamic> appointmentsData = await supabase
          .from(DbTables.appointments)
          .select('id, total_price')
          .eq('barbershop_id', barbershopId)
          .eq('status', 'completed')
          .gte('start_time', startStr)
          .lte('start_time', endStr);

      if (appointmentsData.isEmpty) {
        return ServicesReportEntity(
          periodStart: startDate,
          periodEnd: endDate,
          totalAppointments: 0,
          totalRevenue: 0,
          items: [],
        );
      }

      final appointmentIds = appointmentsData.map((a) => a['id'] as String).toList();
      final totalRevenue = appointmentsData.fold<double>(
        0,
        (sum, a) => sum + ((a['total_price'] as num?)?.toDouble() ?? 0),
      );

      // 2. Fetch appointment_services joined with services for names
      final List<dynamic> servicesData = await supabase
          .from(DbTables.appointmentServices)
          .select('service_id, price, services(name)')
          .inFilter('appointment_id', appointmentIds);

      // 3. Fetch appointment_products joined with products for names
      final List<dynamic> productsData = await supabase
          .from('appointment_products')
          .select('product_id, price, quantity, products(name)')
          .inFilter('appointment_id', appointmentIds);

      // 4. Aggregate services and products by name
      final Map<String, _ServiceAgg> aggregated = {};
      
      for (final item in servicesData) {
        final serviceName =
            (item['services'] as Map<String, dynamic>?)?['name'] as String? ??
                'Servicio desconocido';
        final price = (item['price'] as num?)?.toDouble() ?? 0;

        if (aggregated.containsKey(serviceName)) {
          aggregated[serviceName]!.count++;
          aggregated[serviceName]!.revenue += price;
        } else {
          aggregated[serviceName] = _ServiceAgg(count: 1, revenue: price);
        }
      }

      for (final item in productsData) {
        final rawName =
            (item['products'] as Map<String, dynamic>?)?['name'] as String? ??
                'Producto desconocido';
        final productName = '🛍️ $rawName';
        final price = (item['price'] as num?)?.toDouble() ?? 0;
        final qty = (item['quantity'] as num?)?.toInt() ?? 1;
        final totalCost = price * qty;

        if (aggregated.containsKey(productName)) {
          aggregated[productName]!.count += qty;
          aggregated[productName]!.revenue += totalCost;
        } else {
          aggregated[productName] = _ServiceAgg(count: qty, revenue: totalCost);
        }
      }

      final items = aggregated.entries
          .map((e) => ServicesReportItemEntity(
                serviceName: e.key,
                count: e.value.count,
                revenue: e.value.revenue,
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      return ServicesReportEntity(
        periodStart: startDate,
        periodEnd: endDate,
        totalAppointments: appointmentsData.length,
        totalRevenue: totalRevenue,
        items: items,
      );
    } catch (e) {
      throw ServerException(message: 'Error al generar reporte: $e');
    }
  }
}

class _ServiceAgg {
  int count;
  double revenue;
  _ServiceAgg({required this.count, required this.revenue});
}
