class RemoteSettings {
  final String storeName;
  final String? logoUrl;
  final bool registrationRequired;
  final bool showStock;
  final bool enableGooglePay;
  final String supportEmail;
  final Map<String, String> theme;
  final List<String> enabledPaymentMethods;

  RemoteSettings({
    required this.storeName,
    this.logoUrl,
    required this.registrationRequired,
    required this.showStock,
    required this.enableGooglePay,
    required this.supportEmail,
    required this.theme,
    required this.enabledPaymentMethods,
  });

  factory RemoteSettings.fromJson(Map<String, dynamic> json) {
    return RemoteSettings(
      storeName: json['store_name'] ?? 'Pharos Store',
      logoUrl: json['logo_url'],
      registrationRequired: json['reg_required'] ?? false,
      showStock: json['show_stock'] ?? true,
      enableGooglePay: json['enable_gpay'] ?? true,
      supportEmail: json['support_email'] ?? 'kontakt@pharos.pl',
      theme: Map<String, String>.from(json['theme'] ?? {}),
      enabledPaymentMethods: List<String>.from(json['payment_methods'] ?? []),
    );
  }

  static RemoteSettings defaultSettings() {
    return RemoteSettings(
      storeName: 'PHAROS',
      logoUrl: null,
      registrationRequired: false,
      showStock: true,
      enableGooglePay: true,
      supportEmail: 'kontakt@pharos.pl',
      theme: {'primary_color': '#FF9800'},
      enabledPaymentMethods: ['blik', 'ps_checkout', 'google_pay'],
    );
  }
}
