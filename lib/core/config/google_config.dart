/// Google client configuration for the mobile app.
///
/// Set at build time via --dart-define, e.g.:
/// flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
class GoogleConfig {
  GoogleConfig._();

  /// Web OAuth client ID from Firebase (Authentication -> Google -> Web SDK config).
  /// Required for Google Sign-In on Android when using google_sign_in 7.x.
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static bool get hasServerClientId => serverClientId.isNotEmpty;
}
