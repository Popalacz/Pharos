class RemoteSettings {
  final String storeName;
  final String? logoUrl;
  final bool brandingEnabled;
  final String fontFamily;
  final bool maintenanceMode;
  final String forceUpdateVersion;
  final String? appOnlyDiscountCode;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? tiktokUrl;
  final bool socialMediaEnabled;
  final bool instagramEnabled;
  final bool facebookEnabled;
  final bool tiktokEnabled;
  final String? promoPopupImageUrl;
  final Map<String, String>? eventTheme;
  final double? freeShippingThreshold;
  final bool vouchersEnabled;
  final int? giftCategoryId;

  final String? storeEmail;
  final String? storePhone;
  final String? storeAddress;

  final bool contactMapEnabled;
  final double? latitude;
  final double? longitude;
  final Map<String, List<OpeningHoursEntry>> openingHours;

  final bool publicCalendarEnabled;
  final String? publicCalendarEmbedUrl;
  final Map<String, String> publicCalendarTitle;

  final bool googleMapsEnabled;
  final String? googleMapsApiKey;

  final bool quickContactEnabled;
  final String? quickContactLink;

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
    this.brandingEnabled = true,
    required this.fontFamily,
    required this.maintenanceMode,
    required this.forceUpdateVersion,
    this.appOnlyDiscountCode,
    this.instagramUrl,
    this.facebookUrl,
    this.tiktokUrl,
    this.socialMediaEnabled = false,
    this.instagramEnabled = false,
    this.facebookEnabled = false,
    this.tiktokEnabled = false,
    this.promoPopupImageUrl,
    this.eventTheme,
    this.freeShippingThreshold,
    this.vouchersEnabled = false,
    this.giftCategoryId,
    this.storeEmail,
    this.storePhone,
    this.storeAddress,
    this.contactMapEnabled = false,
    this.latitude,
    this.longitude,
    this.openingHours = const {},
    this.publicCalendarEnabled = false,
    this.publicCalendarEmbedUrl,
    this.publicCalendarTitle = const {},
    this.googleMapsEnabled = false,
    this.googleMapsApiKey,
    this.quickContactEnabled = false,
    this.quickContactLink,
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

  bool get hasVisibleInstagram =>
      socialMediaEnabled && instagramEnabled && _hasUrl(instagramUrl);

  bool get hasVisibleFacebook =>
      socialMediaEnabled && facebookEnabled && _hasUrl(facebookUrl);

  bool get hasVisibleTiktok =>
      socialMediaEnabled && tiktokEnabled && _hasUrl(tiktokUrl);

  bool get hasVisibleSocialMedia =>
      hasVisibleInstagram || hasVisibleFacebook || hasVisibleTiktok;

  bool get hasContactMap =>
      contactMapEnabled &&
      googleMapsEnabled &&
      _hasUrl(googleMapsApiKey) &&
      latitude != null &&
      longitude != null &&
      latitude != 0 &&
      longitude != 0;

  bool get hasPublicCalendar =>
      publicCalendarEnabled && _hasUrl(publicCalendarEmbedUrl);

  String publicCalendarTitleFor(String languageCode) {
    final normalizedLanguage = languageCode.toLowerCase().split('-').first;
    return publicCalendarTitle[normalizedLanguage] ??
        publicCalendarTitle['pl'] ??
        publicCalendarTitle['en'] ??
        'Calendar';
  }

  List<OpeningHoursEntry> openingHoursFor(String languageCode) {
    final normalizedLanguage = languageCode.toLowerCase().split('-').first;
    return openingHours[normalizedLanguage] ??
        openingHours['pl'] ??
        openingHours['en'] ??
        const [];
  }

  bool _hasUrl(String? value) => value != null && value.trim().isNotEmpty;

  RemoteSettings copyWith({
    String? storeName,
    String? logoUrl,
    bool? brandingEnabled,
    String? fontFamily,
    bool? maintenanceMode,
    String? forceUpdateVersion,
    String? appOnlyDiscountCode,
    String? instagramUrl,
    String? facebookUrl,
    String? tiktokUrl,
    bool? socialMediaEnabled,
    bool? instagramEnabled,
    bool? facebookEnabled,
    bool? tiktokEnabled,
    String? promoPopupImageUrl,
    Map<String, String>? eventTheme,
    double? freeShippingThreshold,
    bool? vouchersEnabled,
    int? giftCategoryId,
    String? storeEmail,
    String? storePhone,
    String? storeAddress,
    bool? contactMapEnabled,
    double? latitude,
    double? longitude,
    Map<String, List<OpeningHoursEntry>>? openingHours,
    bool? publicCalendarEnabled,
    String? publicCalendarEmbedUrl,
    Map<String, String>? publicCalendarTitle,
    bool? googleMapsEnabled,
    String? googleMapsApiKey,
    bool? quickContactEnabled,
    String? quickContactLink,
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
      brandingEnabled: brandingEnabled ?? this.brandingEnabled,
      fontFamily: fontFamily ?? this.fontFamily,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      forceUpdateVersion: forceUpdateVersion ?? this.forceUpdateVersion,
      appOnlyDiscountCode: appOnlyDiscountCode ?? this.appOnlyDiscountCode,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      tiktokUrl: tiktokUrl ?? this.tiktokUrl,
      socialMediaEnabled: socialMediaEnabled ?? this.socialMediaEnabled,
      instagramEnabled: instagramEnabled ?? this.instagramEnabled,
      facebookEnabled: facebookEnabled ?? this.facebookEnabled,
      tiktokEnabled: tiktokEnabled ?? this.tiktokEnabled,
      promoPopupImageUrl: promoPopupImageUrl ?? this.promoPopupImageUrl,
      eventTheme: eventTheme ?? this.eventTheme,
      freeShippingThreshold: freeShippingThreshold ?? this.freeShippingThreshold,
      vouchersEnabled: vouchersEnabled ?? this.vouchersEnabled,
      giftCategoryId: giftCategoryId ?? this.giftCategoryId,
      storeEmail: storeEmail ?? this.storeEmail,
      storePhone: storePhone ?? this.storePhone,
      storeAddress: storeAddress ?? this.storeAddress,
      contactMapEnabled: contactMapEnabled ?? this.contactMapEnabled,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openingHours: openingHours ?? this.openingHours,
      publicCalendarEnabled: publicCalendarEnabled ?? this.publicCalendarEnabled,
      publicCalendarEmbedUrl: publicCalendarEmbedUrl ?? this.publicCalendarEmbedUrl,
      publicCalendarTitle: publicCalendarTitle ?? this.publicCalendarTitle,
      googleMapsEnabled: googleMapsEnabled ?? this.googleMapsEnabled,
      googleMapsApiKey: googleMapsApiKey ?? this.googleMapsApiKey,
      quickContactEnabled: quickContactEnabled ?? this.quickContactEnabled,
      quickContactLink: quickContactLink ?? this.quickContactLink,
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
    final socialMedia = appConfig['social_media'] ?? {};
    final engagement = appConfig['engagement_loyalty'] ?? {};
    final contactConfig = json['contact_config'] ?? {};
    final publicCalendar = json['public_calendar'] ?? {};
    final maps = json['maps'] ?? {};

    return RemoteSettings(
      storeName: storeInfo['name'] ?? 'Pharos Store',
      logoUrl: storeInfo['mobile_logo_url'],
      brandingEnabled: storeInfo['enabled'] ?? true,
      fontFamily: design['mobile_typography']?['value'] ?? 'Montserrat',
      maintenanceMode: maintenance['maintenance_mode']?['enabled'] ?? false,
      forceUpdateVersion: maintenance['force_update']?['min_version'] ?? '1.0.0',
      appOnlyDiscountCode: marketing['app_only_discount']?['code'],
      socialMediaEnabled: socialMedia['enabled'] ?? false,
      instagramEnabled: socialMedia['instagram']?['enabled'] ?? false,
      facebookEnabled: socialMedia['facebook']?['enabled'] ?? false,
      tiktokEnabled: socialMedia['tiktok']?['enabled'] ?? false,
      instagramUrl: socialMedia['instagram']?['url'],
      facebookUrl: socialMedia['facebook']?['url'],
      tiktokUrl: socialMedia['tiktok']?['url'],
      promoPopupImageUrl: (marketing['promo_popup'] != null && marketing['promo_popup']['enabled'] == true)
          ? marketing['promo_popup']['image_url']
          : null,
      freeShippingThreshold: (json['free_shipping_threshold'] as num?)?.toDouble(),
      vouchersEnabled: json['vouchers_enabled'] == true,
      giftCategoryId: int.tryParse(json['gift_category_id']?.toString() ?? ''),
      storeEmail: storeInfo['email'],
      storePhone: storeInfo['phone'],
      storeAddress: storeInfo['address'],
      contactMapEnabled: contactConfig['map_enabled'] ?? false,
      latitude: (contactConfig['latitude'] as num?)?.toDouble(),
      longitude: (contactConfig['longitude'] as num?)?.toDouble(),
      openingHours: _parseOpeningHours(contactConfig['opening_hours']),
      publicCalendarEnabled: publicCalendar['enabled'] ?? false,
      publicCalendarEmbedUrl: publicCalendar['embed_url'],
      publicCalendarTitle: _parseLocalizedStrings(publicCalendar['title']),
      googleMapsEnabled: maps['enabled'] ?? false,
      googleMapsApiKey: maps['api_key'],
      quickContactEnabled: engagement['quick_contact']?['enabled'] ?? false,
      quickContactLink: engagement['quick_contact']?['link'],
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

  static Map<String, List<OpeningHoursEntry>> _parseOpeningHours(dynamic rawValue) {
    if (rawValue is! Map) {
      return const {};
    }

    final parsedHours = <String, List<OpeningHoursEntry>>{};
    rawValue.forEach((languageCode, entries) {
      if (entries is! List) {
        return;
      }

      parsedHours[languageCode.toString()] = entries
          .whereType<Map>()
          .map((entry) => OpeningHoursEntry.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    });

    return parsedHours;
  }

  static Map<String, String> _parseLocalizedStrings(dynamic rawValue) {
    if (rawValue is! Map) {
      return const {};
    }

    return rawValue.map((key, value) => MapEntry(key.toString(), value.toString()));
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

class OpeningHoursEntry {
  final String day;
  final String time;

  const OpeningHoursEntry({required this.day, required this.time});

  factory OpeningHoursEntry.fromJson(Map<String, dynamic> json) {
    return OpeningHoursEntry(
      day: json['day']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
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
