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
      storeName: json['store_info']['name'],
      primaryColor: json['store_info']['primary_color'],
      currencySymbol: json['store_info']['currency'],
      sections: (json['home_config'] as List)
          .map((s) => HomeSection.fromJson(s))
          .toList(),
    );
  }
}

enum HomeSectionType {
  BANNER_SLIDER,
  CATEGORY_CHIPS,
  SECTION_HEADER,
  PRODUCT_GRID
}
