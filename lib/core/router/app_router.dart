import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../config/supabase_config.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/employees/presentation/pages/employee_list_page.dart';
import '../../features/employees/presentation/pages/employee_detail_page.dart';
import '../../features/employees/presentation/pages/employee_form_page.dart';
import '../../features/services/presentation/pages/service_list_page.dart';
import '../../features/services/presentation/pages/service_detail_page.dart';
import '../../features/services/presentation/pages/service_form_page.dart';
import '../../features/appointments/presentation/pages/agenda_page.dart';
import '../../features/appointments/presentation/pages/appointment_form_page.dart';
import '../../features/clients/presentation/pages/client_list_page.dart';
import '../../features/clients/presentation/pages/client_form_page.dart';
import '../../features/clients/presentation/pages/commissions_report_page.dart';

/// Main application router configuration.
///
/// Uses GoRouter with:
/// - Auth redirect guard (checks Supabase session)
/// - Nested routes per feature module
final appRouter = GoRouter(
  initialLocation: RouteNames.login,
  debugLogDiagnostics: true,
  redirect: _authGuard,
  routes: [
    // ── Auth Routes (no shell) ──
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),

    // ── Main App Routes (with shell / bottom nav) ──
    GoRoute(
      path: RouteNames.dashboard,
      name: 'dashboard',
      builder: (context, state) => const AgendaPage(),
    ),
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: RouteNames.employees,
      name: 'employees',
      builder: (context, state) => const EmployeeListPage(),
    ),
    GoRoute(
      path: RouteNames.employeeNew,
      name: 'employeeNew',
      builder: (context, state) => const EmployeeFormPage(),
    ),
    GoRoute(
      path: RouteNames.employeeDetail,
      name: 'employeeDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EmployeeDetailPage(id: id);
      },
    ),
    GoRoute(
      path: '/employees/:id/edit',
      name: 'employeeEdit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EmployeeFormPage(employeeId: id);
      },
    ),
    GoRoute(
      path: RouteNames.services,
      name: 'services',
      builder: (context, state) => const ServiceListPage(),
    ),
    GoRoute(
      path: RouteNames.serviceNew,
      name: 'serviceNew',
      builder: (context, state) => const ServiceFormPage(),
    ),
    GoRoute(
      path: RouteNames.serviceDetail,
      name: 'serviceDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ServiceDetailPage(id: id);
      },
    ),
    GoRoute(
      path: '/services/:id/edit',
      name: 'serviceEdit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ServiceFormPage(serviceId: id);
      },
    ),
    GoRoute(
      path: RouteNames.schedule,
      name: 'schedule',
      builder: (context, state) => const AppointmentFormPage(),
    ),
    GoRoute(
      path: RouteNames.clients,
      name: 'clients',
      builder: (context, state) => const ClientListPage(),
    ),
    GoRoute(
      path: RouteNames.clientNew,
      name: 'clientNew',
      builder: (context, state) => const ClientFormPage(),
    ),
    GoRoute(
      path: '/clients/:id/edit',
      name: 'clientEdit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ClientFormPage(clientId: id);
      },
    ),
    GoRoute(
      path: '/reports/commissions',
      name: 'commissionsReport',
      builder: (context, state) => const CommissionsReportPage(),
    ),
  ],
);

/// Global auth guard.
///
/// Redirects to login if the user is not authenticated,
/// and to dashboard if already logged in and trying to access auth pages.
String? _authGuard(BuildContext context, GoRouterState state) {
  final session = SupabaseConfig.client.auth.currentSession;
  final isLoggedIn = session != null;
  final matchedLocation = state.matchedLocation;

  final isAuthRoute = matchedLocation == RouteNames.login ||
      matchedLocation == RouteNames.register ||
      matchedLocation == RouteNames.forgotPassword;

  if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
  if (isLoggedIn && isAuthRoute) return RouteNames.dashboard;
  return null;
}
