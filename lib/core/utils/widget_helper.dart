import 'package:home_widget/home_widget.dart';
import '../../features/appointments/domain/entities/appointment_entity.dart';
import 'date_utils.dart';

abstract class WidgetHelper {
  static const String androidWidgetName = 'BarbershopWidgetProvider';

  /// Updates the Android native Home Screen Widget with today's statistics
  static Future<void> updateHomeScreenWidget(List<AppointmentEntity> todayAppointments) async {
    final now = DateTime.now();

    // 1. Calculate active/pending appointments today
    final activeAppointments = todayAppointments.where((appt) {
      return appt.status != 'cancelled';
    }).toList();

    final int count = activeAppointments.length;

    // 2. Find the next upcoming appointment today
    final upcoming = activeAppointments.where((appt) {
      // Must start in the future (or right now) and not be completed yet
      return appt.startTime.isAfter(now) && appt.status != 'completed';
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    String nextAppointmentStr = 'Sin citas pendientes';
    if (upcoming.isNotEmpty) {
      final nextAppt = upcoming.first;
      final timeStr = AppDateUtils.formatTime(nextAppt.startTime);
      nextAppointmentStr = '$timeStr - ${nextAppt.customerName}';
    }

    try {
      // 3. Write data to the shared container
      await HomeWidget.saveWidgetData<int>('citas_count', count);
      await HomeWidget.saveWidgetData<String>('proxima_cita_time', nextAppointmentStr);

      // 4. Request Android update
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
      );
    } catch (e) {
      // Silent error handler (avoid crash on non-Android during local testing)
    }
  }
}
