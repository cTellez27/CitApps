import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/constants/app_strings.dart';

/// Root widget of CitApps.
///
/// Configures [MaterialApp.router] with:
/// - GoRouter for navigation
/// - Dark and light themes
/// - Spanish locale
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ── App Info ──
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ──
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.light, // Default to light premium theme

      // ── Router ──
      routerConfig: appRouter,

      // ── Locale ──
      locale: const Locale('es', 'CO'),
    );
  }
}
