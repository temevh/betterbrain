// Supabase and Google sign-in settings, read at build time.
//
// Copy config/app_config.example.json to config/app_config.json, fill it in,
// and run with:
//   flutter run --dart-define-from-file=config/app_config.json
//
// config/app_config.json is git-ignored. Only the Supabase anon (publishable)
// key belongs here, never the service role key.

class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // OAuth client IDs from Google Cloud. The web client ID is also entered in
  // Supabase under Authentication > Providers > Google.
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
