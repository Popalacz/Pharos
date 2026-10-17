import 'package:pharos/data/models/product_model.dart';

enum ProductSortOption {
  recommended,
  priceAsc,
  priceDesc,
  nameAsc,
  newest,
}

class ProductListQuery {
  const ProductListQuery({
    this.categoryId,
    this.orderBy = 'id_product',
    this.orderWay = 'DESC',
    this.priceMin,
    this.priceMax,
    this.sortOption = ProductSortOption.recommended,
  });

  final int? categoryId;
  final String orderBy;
  final String orderWay;
  final double? priceMin;
  final double? priceMax;
  final ProductSortOption sortOption;
}

class ProductListFilters {
  static const String sortGroupId = 'sort';
  static const String categoryGroupId = 'category';
  static const String priceGroupId = 'price';

  static ProductListQuery buildQuery({
    required Map<String, List<String>> selectedFilters,
    int? catalogCategoryId,
  }) {
    final sortOption = _resolveSortOption(selectedFilters[sortGroupId]);
    final order = _resolveOrder(sortOption);

    int? categoryId = catalogCategoryId;
    final selectedCategories = selectedFilters[categoryGroupId] ?? [];
    if (selectedCategories.isNotEmpty) {
      categoryId = int.tryParse(selectedCategories.first);
    }

    final priceRange = _resolvePriceRange(selectedFilters[priceGroupId]);

    return ProductListQuery(
      categoryId: categoryId,
      orderBy: order.orderBy,
      orderWay: order.orderWay,
      priceMin: priceRange.min,
      priceMax: priceRange.max,
      sortOption: sortOption,
    );
  }

  static List<ProductModel> apply({
    required List<ProductModel> products,
    required Map<String, List<String>> selectedFilters,
  }) {
    var filteredProducts = List<ProductModel>.from(products);

    final priceRange = _resolvePriceRange(selectedFilters[priceGroupId]);
    if (priceRange.min != null || priceRange.max != null) {
      filteredProducts = filteredProducts.where((product) {
        if (priceRange.min != null && product.price < priceRange.min!) {
          return false;
        }
        if (priceRange.max != null && product.price > priceRange.max!) {
          return false;
        }
        return true;
      }).toList();
    }

    final sortOption = _resolveSortOption(selectedFilters[sortGroupId]);
    return _sortProducts(filteredProducts, sortOption);
  }

  static Map<String, String> buildAttributeAndFeatureParams(
    Map<String, List<String>> selectedFilters,
  ) {
    final params = <String, String>{};

    selectedFilters.forEach((groupId, values) {
      if (values.isEmpty) {
        return;
      }

      if (groupId.startsWith('feature_') || groupId.startsWith('attribute_group_')) {
        params[groupId] = values.join(',');
      }
    });

    return params;
  }

  static bool hasServerSideFilters(Map<String, List<String>> selectedFilters) {
    return selectedFilters.keys.any(
      (groupId) => groupId.startsWith('feature_') || groupId.startsWith('attribute_group_'),
    );
  }

  static ProductSortOption _resolveSortOption(List<String>? selectedSortValues) {
    if (selectedSortValues == null || selectedSortValues.isEmpty) {
      return ProductSortOption.recommended;
    }

    return ProductSortOption.values.firstWhere(
      (option) => option.name == selectedSortValues.first,
      orElse: () => ProductSortOption.recommended,
    );
  }

  static _OrderMapping _resolveOrder(ProductSortOption sortOption) {
    switch (sortOption) {
      case ProductSortOption.priceAsc:
        return const _OrderMapping(orderBy: 'price', orderWay: 'ASC');
      case ProductSortOption.priceDesc:
        return const _OrderMapping(orderBy: 'price', orderWay: 'DESC');
      case ProductSortOption.nameAsc:
        return const _OrderMapping(orderBy: 'name', orderWay: 'ASC');
      case ProductSortOption.newest:
        return const _OrderMapping(orderBy: 'date_add', orderWay: 'DESC');
      case ProductSortOption.recommended:
        return const _OrderMapping(orderBy: 'position', orderWay: 'ASC');
    }
  }

  static _PriceRange _resolvePriceRange(List<String>? selectedPriceValues) {
    if (selectedPriceValues == null || selectedPriceValues.isEmpty) {
      return const _PriceRange();
    }

    switch (selectedPriceValues.first) {
      case 'p1':
        return const _PriceRange(max: 100);
      case 'p2':
        return const _PriceRange(min: 100, max: 500);
      case 'p3':
        return const _PriceRange(min: 500);
      default:
        return const _PriceRange();
    }
  }

  static List<ProductModel> _sortProducts(
    List<ProductModel> products,
    ProductSortOption sortOption,
  ) {
    final sortedProducts = List<ProductModel>.from(products);

    switch (sortOption) {
      case ProductSortOption.priceAsc:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.nameAsc:
        sortedProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ProductSortOption.newest:
        sortedProducts.sort((a, b) => b.id.compareTo(a.id));
        break;
      case ProductSortOption.recommended:
        break;
    }

    return sortedProducts;
  }
}

class _OrderMapping {
  const _OrderMapping({required this.orderBy, required this.orderWay});

  final String orderBy;
  final String orderWay;
}

class _PriceRange {
  const _PriceRange({this.min, this.max});

  final double? min;
  final double? max;
}
