class RemoteSettings {
  final bool registrationRequired;
  final bool showStock;
  final bool enableGooglePay;
  final String supportEmail;
  final Map<String, String> theme;
  final List<String> enabledPaymentMethods;

  RemoteSettings({
    required this.registrationRequired,
    required this.showStock,
    required this.enableGooglePay,
    required this.supportEmail,
    required this.theme,
    required this.enabledPaymentMethods,
  });

  factory RemoteSettings.fromJson(Map<String, dynamic> json) {
    return RemoteSettings(
      registrationRequired: json['reg_required'] ?? false,
      showStock: json['show_stock'] ?? true,
      enableGooglePay: json['enable_gpay'] ?? true,
      supportEmail: json['support_email'] ?? 'kontakt@pharos.pl',
      theme: Map<String, String>.from(json['theme'] ?? {}),
      enabledPaymentMethods: List<String>.from(json['payment_methods'] ?? []),
    );
  }
}
