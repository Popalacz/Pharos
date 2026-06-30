import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pharos/core/api/api_config.dart';
import 'converters/defensive_json_converters.dart';

part 'product_model.freezed.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    @DefensiveIntConverter() required int id,
    @DefensiveStringConverter() @Default('') String name,
    @DefensiveStringConverter() @Default('') String description,
    @DefensiveDoubleConverter() @Default(0) double price,
    @DefensiveNullableDoubleConverter() @JsonKey(name: 'price_old') double? priceOld,
    @DefensiveNullableIntConverter() @JsonKey(name: 'discount_percentage') int? discountPercentage,
    @Default([]) List<String> images,
    @JsonKey(name: 'imageUrl') @Default('') String imageUrl,
    @DefensiveIntConverter() @JsonKey(name: 'stock') @Default(0) int stockQuantity,
    @DefensiveBoolConverter() @JsonKey(name: 'out_of_stock') @Default(false) bool allowOutOfStockOrders,
    @DefensiveBoolConverter() @JsonKey(name: 'available_for_order') @Default(true) bool availableForOrder,
    @DefensiveIntConverter() @JsonKey(name: 'minimal_quantity') @Default(1) int minimalQuantity,
    @DefensiveStringConverter() @Default('') String reference,
    @DefensiveStringConverter() @JsonKey(name: 'manufacturer_name') @Default('') String manufacturerName,
    @DefensiveStringConverter() @JsonKey(name: 'available_now') @Default('') String availableNowLabel,
    @DefensiveStringConverter() @JsonKey(name: 'available_later') @Default('') String availableLaterLabel,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final normalized = _normalizeProductJson(json);
    final id = const DefensiveIntConverter().fromJson(normalized['id']);

    return ProductModel(
      id: id,
      name: const DefensiveStringConverter().fromJson(normalized['name']),
      description: const DefensiveStringConverter().fromJson(normalized['description']),
      price: const DefensiveDoubleConverter().fromJson(normalized['price']),
      priceOld: const DefensiveNullableDoubleConverter().fromJson(normalized['price_old']),
      discountPercentage: const DefensiveNullableIntConverter().fromJson(normalized['discount_percentage']),
      images: _resolveImages(json, id),
      imageUrl: _resolveImageUrl(json, id),
      stockQuantity: const DefensiveIntConverter().fromJson(normalized['stock']),
      allowOutOfStockOrders: _resolveAllowOutOfStock(json),
      availableForOrder: const DefensiveBoolConverter().fromJson(normalized['available_for_order']),
      minimalQuantity: const DefensiveIntConverter().fromJson(normalized['minimal_quantity']),
      reference: const DefensiveStringConverter().fromJson(normalized['reference']),
      manufacturerName: const DefensiveStringConverter().fromJson(normalized['manufacturer_name']),
      availableNowLabel: const DefensiveStringConverter().fromJson(normalized['available_now']),
      availableLaterLabel: const DefensiveStringConverter().fromJson(normalized['available_later']),
    );
  }

  bool get hasDiscount => priceOld != null && priceOld! > price;
  bool get canBeAddedToCart =>
      availableForOrder && (stockQuantity >= minimalQuantity || allowOutOfStockOrders);
  bool get shouldShowNotifyMe =>
      availableForOrder && stockQuantity <= 0 && !allowOutOfStockOrders;
  bool get isOnOrder => stockQuantity <= 0 && allowOutOfStockOrders;
  bool get isAvailable => stockQuantity >= minimalQuantity || allowOutOfStockOrders;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  String getSizedImageUrl([String size = 'home_default']) {
    if (imageUrl.isEmpty) return '';
    if (!imageUrl.contains('/api/images/')) return imageUrl;
    if (imageUrl.contains('?')) {
      final parts = imageUrl.split('?');
      return '${parts[0]}/$size?${parts[1]}';
    }
    return '$imageUrl/$size';
  }

  List<String> getSizedImages([String size = 'large_default']) {
    return images.map((url) {
      if (!url.contains('/api/images/')) return url;
      if (url.contains('?')) {
        final parts = url.split('?');
        return '${parts[0]}/$size?${parts[1]}';
      }
      return '$url/$size';
    }).toList();
  }

  static Map<String, dynamic> _normalizeProductJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    if (normalized['description'] == null && normalized['description_short'] != null) {
      normalized['description'] = normalized['description_short'];
    }
    if (normalized['stock'] == null && normalized['quantity'] != null) {
      normalized['stock'] = normalized['quantity'];
    }
    if (normalized['image'] != null && normalized['imageUrl'] == null) {
      normalized['imageUrl'] = normalized['image'];
    }
    return normalized;
  }

  static List<String> _resolveImages(Map<String, dynamic> json, int productId) {
    final images = <String>[];
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      images.add(json['image'].toString());
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      images.addAll((json['images'] as List).map((e) => e.toString()));
    } else if (json['image_ws'] != null) {
      images.add(json['image_ws'].toString());
    } else if (json['id_default_image'] != null && json['id_default_image'] != '0') {
      final imgId = json['id_default_image'].toString();
      final apiBase = ApiConfig.baseUrl.split('/api').first;
      images.add('$apiBase/api/images/products/$productId/$imgId');
    }
    return images.map((url) => _stabilizeImageUrl(url, productId)).where((url) => url.isNotEmpty).toList();
  }

  static String _resolveImageUrl(Map<String, dynamic> json, int productId) {
    final images = _resolveImages(json, productId);
    return images.isNotEmpty ? images.first : '';
  }

  static bool _resolveAllowOutOfStock(Map<String, dynamic> json) {
    final outOfStock = json['out_of_stock'];
    if (outOfStock == '1' || outOfStock == '2' || outOfStock == 1 || outOfStock == 2) {
      return true;
    }
    final stock = int.tryParse((json['stock'] ?? json['quantity'] ?? '0').toString()) ?? 0;
    return stock > 0;
  }

  static String _stabilizeImageUrl(String url, int productId) {
    if (url.isEmpty) return '';
    final apiBase = ApiConfig.baseUrl.split('/api').first;
    String finalUrl = url;
    if (!finalUrl.startsWith('http')) {
      finalUrl = '$apiBase${finalUrl.startsWith('/') ? '' : '/'}$finalUrl';
    }
    finalUrl = finalUrl.replaceFirst('://', '@@@').replaceAll('//', '/').replaceFirst('@@@', '://');
    if (finalUrl.contains('/api/images/') && !finalUrl.toLowerCase().contains('.jpg')) {
      if (!finalUrl.contains('ws_key=')) {
        finalUrl += '${finalUrl.contains('?') ? '&' : '?'}ws_key=${ApiConfig.apiKey}';
      }
    }
    return finalUrl;
  }
}

extension ProductModelJson on ProductModel {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'price_old': priceOld,
        'discount_percentage': discountPercentage,
        'images': images,
        'imageUrl': imageUrl,
        'quantity': stockQuantity,
        'out_of_stock': allowOutOfStockOrders ? '1' : '0',
        'available_for_order': availableForOrder,
        'minimal_quantity': minimalQuantity,
        'reference': reference,
        'manufacturer_name': manufacturerName,
        'available_now': availableNowLabel,
        'available_later': availableLaterLabel,
      };
}
