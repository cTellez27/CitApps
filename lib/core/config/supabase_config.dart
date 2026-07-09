import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Supabase initialization and client access.
///
/// Call [SupabaseConfig.initialize] once in `main.dart` before runApp.
/// Access the client via [SupabaseConfig.client] anywhere in the app.
abstract class SupabaseConfig {
  /// Initializes Supabase with project credentials.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  /// Returns the Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;
}
