class RemoteSettings {
  final String storeName;
  final String? logoUrl;
  final String fontFamily;
  final bool maintenanceMode;
  final String forceUpdateVersion;
  final String? appOnlyDiscountCode;
  final String? whatsappNumber;
  final Map<String, String>? eventTheme;
  final double freeShippingThreshold;
  
  // Feature Flags from Growth Guidelines
  final bool recentlyViewedEnabled;
  final bool cartRecoveryEnabled;
  final bool lowStockBadgeEnabled;

  // Debug Flags
  final bool appDebug;
  final bool useMockData;

  // Design
  final Map<String, String> theme;
  
  // Marketing
  final List<OnboardingSlide> onboarding;
  final List<String> enabledPaymentMethods;

  RemoteSettings({
    required this.storeName,
    this.logoUrl,
    required this.fontFamily,
    required this.maintenanceMode,
    required this.forceUpdateVersion,
    this.appOnlyDiscountCode,
    this.whatsappNumber,
    this.eventTheme,
    required this.freeShippingThreshold,
    this.recentlyViewedEnabled = true,
    this.cartRecoveryEnabled = true,
    this.lowStockBadgeEnabled = true,
    required this.appDebug,
    required this.useMockData,
    required this.theme,
    required this.onboarding,
    required this.enabledPaymentMethods,
  });

  factory RemoteSettings.fromJson(Map<String, dynamic> json) {
    return RemoteSettings(
      storeName: json['store_name'] ?? 'Pharos Store',
      logoUrl: json['logo_url'],
      fontFamily: json['font_family'] ?? 'Montserrat',
      maintenanceMode: json['maintenance_mode'] ?? false,
      forceUpdateVersion: json['force_update_version'] ?? '1.0.0',
      appOnlyDiscountCode: json['app_discount'],
      whatsappNumber: json['whatsapp'],
      eventTheme: json['event_theme'] != null ? Map<String, String>.from(json['event_theme']) : null,
      freeShippingThreshold: double.tryParse(json['free_shipping_threshold']?.toString() ?? '200.0') ?? 200.0,
      recentlyViewedEnabled: json['recently_viewed_enabled'] ?? true,
      cartRecoveryEnabled: json['cart_recovery_enabled'] ?? true,
      lowStockBadgeEnabled: json['low_stock_badge_enabled'] ?? true,
      appDebug: json['app_config']?['app_debug'] ?? false,
      useMockData: json['app_config']?['use_mock_data'] ?? false,
      theme: Map<String, String>.from(json['theme'] ?? {}),
      onboarding: (json['onboarding'] as List? ?? [])
          .map((item) => OnboardingSlide.fromJson(item))
          .toList(),
      enabledPaymentMethods: List<String>.from(json['payment_methods'] ?? []),
    );
  }

  static RemoteSettings defaultSettings() {
    return RemoteSettings(
      storeName: 'PHAROS',
      fontFamily: 'Montserrat',
      maintenanceMode: false,
      forceUpdateVersion: '1.0.0',
      freeShippingThreshold: 200.0,
      appDebug: false,
      useMockData: false,
      theme: {'primary_color': '#FF9800'},
      onboarding: [],
      enabledPaymentMethods: ['blik', 'ps_checkout', 'google_pay'],
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String imageUrl;

  OnboardingSlide({required this.title, required this.description, required this.imageUrl});

  factory OnboardingSlide.fromJson(Map<String, dynamic> json) {
    return OnboardingSlide(
      title: json['title'] ?? '',
      description: json['desc'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }
}
