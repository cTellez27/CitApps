/// Route name constants for GoRouter navigation.
///
/// Centralizes all route paths to prevent typos
/// and enable easy refactoring.
library;

abstract class RouteNames {
  // ── Auth ──
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String onboarding = '/onboarding';

  // ── Main App ──
  static const String dashboard = '/';
  static const String clients = '/clients';
  static const String clientDetail = '/clients/:id';
  static const String clientNew = '/clients/new';
  static const String employees = '/employees';
  static const String employeeDetail = '/employees/:id';
  static const String employeeNew = '/employees/new';
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String serviceNew = '/services/new';
  static const String schedule = '/schedule';
  static const String appointmentNew = '/schedule/new';
  static const String appointmentDetail = '/schedule/:id';
  static const String inventory = '/inventory';
  static const String productDetail = '/inventory/:id';
  static const String productNew = '/inventory/new';
  static const String sales = '/sales';
  static const String saleDetail = '/sales/:id';
  static const String saleNew = '/sales/new';
  static const String cashRegister = '/cash-register';
  static const String reports = '/reports';
  static const String settings = '/settings';
}
