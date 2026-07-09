import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

/// Entry point of CitApps.
///
/// Initializes:
/// 1. Flutter bindings
/// 2. System UI overlay style
/// 3. Supabase client
/// 4. Wraps the app with [ProviderScope] for Riverpod
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting locale
  await initializeDateFormatting('es', null);

  // Lock to portrait mode for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
