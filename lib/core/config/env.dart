/// Environment configuration for Supabase credentials.
///
/// In production, these values should be loaded from
/// environment variables or a secure configuration file.
/// For now, they are placeholder constants that must be
/// replaced with actual Supabase project credentials.
library;

abstract class Env {
  /// Supabase project URL.
  static const String supabaseUrl = 'https://xoirnmjbwhntarpwnkcl.supabase.co';

  /// Supabase publishable (public) API key.
  static const String supabaseAnonKey = 'sb_publishable_QriEG3UStYgg6mNDkL83QQ_PW0OXLZf';
}
