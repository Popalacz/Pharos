import 'package:flutter/material.dart';
import 'package:pharos/data/models/home_config_model.dart';
import 'package:pharos/ui/sdui/sdui_sections.dart';

typedef CategorySelectedCallback = void Function(int? categoryId);

class SduiMapper {
  const SduiMapper();

  Map<String, dynamic> resolveSectionData(Map<String, dynamic> section) {
    if (section['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(section['data'] as Map);
    }

    return {
      if (section['items'] != null) 'items': section['items'],
      if (section['title'] != null) 'title': section['title'],
    };
  }

  bool shouldSkipSection(Map<String, dynamic> section) {
    final typeStr = section['type']?.toString() ?? '';
    if (typeStr.isEmpty) return true;

    final type = HomeSectionType.values.firstWhere(
      (value) => value.name == typeStr,
      orElse: () => HomeSectionType.SECTION_HEADER,
    );

    final data = resolveSectionData(section);
    final items = data['items'];

    if (items is List && items.isEmpty && type != HomeSectionType.SECTION_HEADER) {
      return true;
    }

    if (type == HomeSectionType.SECTION_HEADER && (data['title']?.toString().isEmpty ?? true)) {
      return true;
    }

    return false;
  }

  Widget mapSectionAsSliver(
    BuildContext context,
    Map<String, dynamic> section, {
    int? selectedCategoryId,
    CategorySelectedCallback? onCategorySelected,
  }) {
    if (shouldSkipSection(section)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final typeStr = section['type'] as String;
    final data = resolveSectionData(section);
    final type = HomeSectionType.values.firstWhere(
      (value) => value.name == typeStr,
      orElse: () => HomeSectionType.SECTION_HEADER,
    );

    switch (type) {
      case HomeSectionType.BANNER_SLIDER:
        return SliverToBoxAdapter(child: BannerSliderSection(data: data));
      case HomeSectionType.CATEGORY_CHIPS:
        return SliverToBoxAdapter(
          child: CategoryChipsSection(
            data: data,
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: onCategorySelected ?? (_) {},
          ),
        );
      case HomeSectionType.SECTION_HEADER:
        return SliverToBoxAdapter(child: SectionHeaderWidget(data: data));
      case HomeSectionType.PRODUCT_GRID:
        return SliverToBoxAdapter(child: ProductGridSection(data: data));
      case HomeSectionType.RECOMMENDATIONS:
        return SliverToBoxAdapter(child: RecommendationsSection(data: data));
    }
  }
}
