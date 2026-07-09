import 'package:intl/intl.dart';

/// Date and time formatting utilities.
///
/// Provides Spanish-locale formatting for dates and times
/// used across the application.
abstract class AppDateUtils {
  // ── Formatters ──
  static final _dateFormatter = DateFormat('dd/MM/yyyy', 'es');
  static final _dateShortFormatter = DateFormat('dd MMM', 'es');
  static final _dateLongFormatter = DateFormat('EEEE dd \'de\' MMMM', 'es');
  static final _timeFormatter = DateFormat('HH:mm', 'es');
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es');

  /// Formats as "08/07/2026"
  static String formatDate(DateTime date) => _dateFormatter.format(date);

  /// Formats as "08 Jul"
  static String formatDateShort(DateTime date) => _dateShortFormatter.format(date);

  /// Formats as "martes 08 de julio"
  static String formatDateLong(DateTime date) => _dateLongFormatter.format(date);

  /// Formats as "14:30"
  static String formatTime(DateTime dateTime) => _timeFormatter.format(dateTime);

  /// Formats a TimeOfDay-like time string. "14:30" → "02:30 PM" or "14:30"
  static String formatTimeString(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final dt = DateTime(2000, 1, 1, hour, minute);
    return _timeFormatter.format(dt);
  }

  /// Formats as "08/07/2026 14:30"
  static String formatDateTime(DateTime dateTime) => _dateTimeFormatter.format(dateTime);

  /// Returns relative time string: "Hace 5 min", "Hoy", "Ayer", etc.
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24 && now.day == dateTime.day) return 'Hoy ${formatTime(dateTime)}';
    if (diff.inHours < 48) return 'Ayer ${formatTime(dateTime)}';
    if (diff.inDays < 7) return '${_dayName(dateTime.weekday)} ${formatTime(dateTime)}';
    return formatDate(dateTime);
  }

  /// Returns the day of the week name in Spanish.
  static String _dayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }

  /// Returns the full day name in Spanish.
  static String dayNameFull(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  /// Checks if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Returns start of day (00:00:00).
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

  /// Returns end of day (23:59:59).
  static DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);
}
