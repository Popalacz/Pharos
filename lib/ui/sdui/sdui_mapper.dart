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

  List<Map<String, dynamic>> filterVisibleSections(List sectionsData) {
    final sections = sectionsData
        .whereType<Map>()
        .map((section) => Map<String, dynamic>.from(section))
        .toList();

    final visibleSections = <Map<String, dynamic>>[];
    for (var index = 0; index < sections.length; index++) {
      final section = sections[index];
      final type = section['type']?.toString() ?? '';

      if (type == 'SECTION_HEADER' && !_hasProductsAfter(sections, index)) {
        continue;
      }

      if ((type == 'PRODUCT_GRID' || type == 'RECOMMENDATIONS') && !_sectionHasItems(section)) {
        continue;
      }

      visibleSections.add(section);
    }

    return visibleSections;
  }

  bool _sectionHasItems(Map<String, dynamic> section) {
    final items = resolveSectionData(section)['items'];
    return items is List && items.isNotEmpty;
  }

  bool _hasProductsAfter(List<Map<String, dynamic>> sections, int headerIndex) {
    for (var index = headerIndex + 1; index < sections.length; index++) {
      final type = sections[index]['type']?.toString() ?? '';
      if (type == 'SECTION_HEADER') {
        return false;
      }
      if (type == 'PRODUCT_GRID' || type == 'RECOMMENDATIONS') {
        return _sectionHasItems(sections[index]);
      }
    }
    return false;
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

    final typeStr = section['type']?.toString() ?? '';
    if (typeStr.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

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
