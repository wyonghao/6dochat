/// Application configuration for Discourse integration.
///
/// Replace these values before running the app.
class AppConfig {
  /// Example: https://meta.discourse.org
  static const String discourseBaseUrl = 'https://your-discourse-instance.com';

  /// OAuth client id configured on your Discourse instance.
  static const String oauthClientId = 'your-oauth-client-id';

  /// OAuth redirect URL configured in Discourse.
  static const String oauthRedirectUri = 'com.example.dochat://oauth-callback';

  /// Discourse OAuth authorize endpoint.
  static String get authorizeUrl => '$discourseBaseUrl/oauth/authorize';

  /// Discourse OAuth token endpoint.
  static String get tokenUrl => '$discourseBaseUrl/oauth/token';

  /// Polling interval for refreshing channel messages.
  static const Duration pollingInterval = Duration(seconds: 7);
}
