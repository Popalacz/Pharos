import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharos/data/models/category_model.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/ui/widgets/pharos_product_card.dart';
import 'package:pharos/l10n/app_localizations.dart';

List<ProductModel> _parseProductItems(List items) {
  final products = <ProductModel>[];
  for (final item in items) {
    if (item is! Map) continue;
    try {
      products.add(ProductModel.fromJson(Map<String, dynamic>.from(item)));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('ProductGridSection: skip invalid product item: $error\n$stackTrace');
      }
    }
  }
  return products;
}

class BannerSliderSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const BannerSliderSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data['items'] as List? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index] as Map<String, dynamic>;
          final imageUrl = item['image']?.toString() ?? '';
          if (imageUrl.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Text(
                item['title']?.toString() ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryChipsSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const CategoryChipsSection({
    super.key,
    required this.data,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = data['items'] as List? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final categories = items.map((item) {
      if (item is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(item));
      }
      return null;
    }).whereType<CategoryModel>().toList();

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip('Wszystko', null);
          }
          final category = categories[index - 1];
          return _buildChip(category.name, category.id);
        },
      ),
    );
  }

  Widget _buildChip(String label, int? id) {
    final isSelected = selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onCategorySelected(id),
        selectedColor: Colors.orange,
        backgroundColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      ),
    );
  }
}

class SectionHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onSeeAll;

  const SectionHeaderWidget({super.key, required this.data, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Sekcja';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(AppLocalizations.of(context)!.seeAll, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class ProductGridSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final String heroTagPrefix;

  const ProductGridSection({
    super.key,
    required this.data,
    this.heroTagPrefix = 'home',
  });

  @override
  Widget build(BuildContext context) {
    final items = data['items'] as List? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final products = _parseProductItems(items);
    if (products.isEmpty) return const SizedBox.shrink();

    final title = data['title']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title.isNotEmpty) SectionHeaderWidget(data: {'title': title}),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) => PharosProductCard(product: products[index], heroTagPrefix: heroTagPrefix),
          ),
        ),
      ],
    );
  }
}

class RecommendationsSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const RecommendationsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = data['items'] as List? ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final products = _parseProductItems(items);
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeaderWidget(data: {'title': data['title']?.toString() ?? 'Polecane'}),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: PharosProductCard(product: products[index], heroTagPrefix: 'reco'),
              );
            },
          ),
        ),
      ],
    );
  }
}
