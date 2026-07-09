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
      builder: (context, state) => const _PlaceholderPage(title: 'Dashboard (Fase 2)'),
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

/// Temporary placeholder page used until actual feature pages are built.
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
