class RemoteSettings {
  final String storeName;
  final String? logoUrl;
  final String fontFamily;
  final bool maintenanceMode;
  final String forceUpdateVersion;
  final String? appOnlyDiscountCode;
  final String? whatsappNumber;
  final Map<String, String>? eventTheme;
  final double? freeShippingThreshold;
  final bool vouchersEnabled;
  final int? giftCategoryId;

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
    this.freeShippingThreshold,
    this.vouchersEnabled = false,
    this.giftCategoryId,
    this.recentlyViewedEnabled = true,
    this.cartRecoveryEnabled = true,
    this.lowStockBadgeEnabled = true,
    required this.appDebug,
    required this.useMockData,
    required this.theme,
    required this.onboarding,
    required this.enabledPaymentMethods,
  });

  bool get hasFreeShippingProgress => freeShippingThreshold != null && freeShippingThreshold! > 0;

  RemoteSettings copyWith({
    String? storeName,
    String? logoUrl,
    String? fontFamily,
    bool? maintenanceMode,
    String? forceUpdateVersion,
    String? appOnlyDiscountCode,
    String? whatsappNumber,
    Map<String, String>? eventTheme,
    double? freeShippingThreshold,
    bool? vouchersEnabled,
    int? giftCategoryId,
    bool? recentlyViewedEnabled,
    bool? cartRecoveryEnabled,
    bool? lowStockBadgeEnabled,
    bool? appDebug,
    bool? useMockData,
    Map<String, String>? theme,
    List<OnboardingSlide>? onboarding,
    List<String>? enabledPaymentMethods,
  }) {
    return RemoteSettings(
      storeName: storeName ?? this.storeName,
      logoUrl: logoUrl ?? this.logoUrl,
      fontFamily: fontFamily ?? this.fontFamily,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      forceUpdateVersion: forceUpdateVersion ?? this.forceUpdateVersion,
      appOnlyDiscountCode: appOnlyDiscountCode ?? this.appOnlyDiscountCode,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      eventTheme: eventTheme ?? this.eventTheme,
      freeShippingThreshold: freeShippingThreshold ?? this.freeShippingThreshold,
      vouchersEnabled: vouchersEnabled ?? this.vouchersEnabled,
      giftCategoryId: giftCategoryId ?? this.giftCategoryId,
      recentlyViewedEnabled: recentlyViewedEnabled ?? this.recentlyViewedEnabled,
      cartRecoveryEnabled: cartRecoveryEnabled ?? this.cartRecoveryEnabled,
      lowStockBadgeEnabled: lowStockBadgeEnabled ?? this.lowStockBadgeEnabled,
      appDebug: appDebug ?? this.appDebug,
      useMockData: useMockData ?? this.useMockData,
      theme: theme ?? this.theme,
      onboarding: onboarding ?? this.onboarding,
      enabledPaymentMethods: enabledPaymentMethods ?? this.enabledPaymentMethods,
    );
  }

  factory RemoteSettings.fromJson(Map<String, dynamic> json) {
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
      whatsappNumber: appConfig['social_media']?['instagram']?['url'],
      freeShippingThreshold: (json['free_shipping_threshold'] as num?)?.toDouble(),
      vouchersEnabled: json['vouchers_enabled'] == true,
      giftCategoryId: int.tryParse(json['gift_category_id']?.toString() ?? ''),
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
      appDebug: false,
      useMockData: false,
      theme: {'primary_color': '#FF9800'},
      onboarding: [],
      enabledPaymentMethods: [],
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
