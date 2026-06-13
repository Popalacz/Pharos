enum HomeSectionType {
  BANNER_SLIDER,
  CATEGORY_CHIPS,
  SECTION_HEADER,
  PRODUCT_GRID
}

class HomeSection {
  final HomeSectionType type;
  final dynamic data;

  HomeSection({required this.type, required this.data});

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      type: HomeSectionType.values.firstWhere((e) => e.name == json['type']),
      data: json['data'],
    );
  }
}

class HomeConfig {
  final String storeName;
  final String primaryColor;
  final String currencySymbol;
  final List<HomeSection> sections;

  HomeConfig({
    required this.storeName,
    required this.primaryColor,
    required this.currencySymbol,
    required this.sections,
  });

  factory HomeConfig.fromJson(Map<String, dynamic> json) {
    return HomeConfig(
      storeName: json['store_info']['name'] ?? 'Pharos Store',
      primaryColor: json['store_info']['primary_color'] ?? '#FF9800',
      currencySymbol: json['store_info']['currency'] ?? 'PLN',
      sections: (json['home_config'] as List)
          .map((s) => HomeSection.fromJson(s))
          .toList(),
    );
  }
}
