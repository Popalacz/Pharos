/// Links to the store legal pages shown in the checkout.
///
/// Set at build time via --dart-define, e.g.:
/// flutter run --dart-define=TERMS_URL=https://shop.example/terms
class LegalConfig {
  LegalConfig._();

  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: '',
  );

  static const String privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: '',
  );

  static const String withdrawalUrl = String.fromEnvironment(
    'WITHDRAWAL_URL',
    defaultValue: '',
  );
}
