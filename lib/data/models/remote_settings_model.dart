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
  
  final bool recentlyViewedEnabled;
  final bool cartRecoveryEnabled;
  final bool lowStockBadgeEnabled;

  final bool appDebug;
  final bool useMockData;

  final Map<String, String> theme;
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
    // Mapowanie pod strukturę z modułu pharosapi
    final storeInfo = json['store_info'] ?? {};
    final appConfig = json['app_config'] ?? {};
    final design = appConfig['design_overrides'] ?? {};
    final marketing = appConfig['marketing_onboarding'] ?? {};
    final growth = appConfig['growth_experience'] ?? {};
    final maintenance = appConfig['maintenance'] ?? {};

    return RemoteSettings(
      storeName: storeInfo['name'] ?? 'Pharos Store',
      logoUrl: storeInfo['mobile_logo_url'],
      fontFamily: design['mobile_typography']?['value'] ?? 'Montserrat',
      maintenanceMode: maintenance['maintenance_mode']?['enabled'] ?? false,
      forceUpdateVersion: maintenance['force_update']?['min_version'] ?? '1.0.0',
      appOnlyDiscountCode: marketing['app_only_discount']?['code'],
      whatsappNumber: appConfig['social_media']?['instagram']?['url'], // Przykładowe użycie
      freeShippingThreshold: (json['free_shipping_threshold'] as num?)?.toDouble() ?? 200.0,
      recentlyViewedEnabled: growth['recently_viewed']?['enabled'] ?? true,
      cartRecoveryEnabled: growth['cart_recovery_banner']?['enabled'] ?? true,
      lowStockBadgeEnabled: growth['low_stock_badge']?['enabled'] ?? true,
      appDebug: appConfig['app_debug'] ?? false,
      useMockData: appConfig['use_mock_data'] ?? false,
      theme: {
        'primary_color': storeInfo['primary_color'] ?? '#FF9800',
        'card_style': design['product_card_style']?['value'] ?? 'standard',
      },
      onboarding: (marketing['onboarding']?['slides'] as List? ?? [])
          .map((item) => OnboardingSlide.fromJson(item))
          .toList(),
      enabledPaymentMethods: (json['payments'] as List? ?? [])
          .map((item) => item['name'].toString())
          .toList(),
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
      description: json['description'] ?? json['desc'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? '',
    );
  }
}
