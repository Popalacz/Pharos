import 'package:pharos/core/api/api_config.dart';
import 'package:flutter/foundation.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? priceOld;
  final int? discountPercentage;
  final List<String> images;
  final String imageUrl;
  final int stockQuantity;
  final bool allowOutOfStockOrders;
  final bool availableForOrder;
  final int minimalQuantity;
  final String reference;
  final String manufacturerName;
  final String availableNowLabel;
  final String availableLaterLabel;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.priceOld,
    this.discountPercentage,
    required this.images,
    required this.imageUrl,
    required this.stockQuantity,
    required this.allowOutOfStockOrders,
    required this.availableForOrder,
    this.minimalQuantity = 1,
    this.reference = '',
    this.manufacturerName = '',
    this.availableNowLabel = '',
    this.availableLaterLabel = '',
  });

  bool get hasDiscount => priceOld != null && priceOld! > price;
  bool get canBeAddedToCart => availableForOrder && (stockQuantity >= minimalQuantity || allowOutOfStockOrders);
  bool get shouldShowNotifyMe => availableForOrder && stockQuantity <= 0 && !allowOutOfStockOrders;
  bool get isOnOrder => stockQuantity <= 0 && allowOutOfStockOrders;
  bool get isAvailable => stockQuantity >= minimalQuantity || allowOutOfStockOrders;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  static String _stabilizeImageUrl(String url, int productId) {
    if (url.isEmpty) return '';
    
    final String apiBase = ApiConfig.baseUrl.split('/api').first;
    String finalUrl = url;
    
    if (!finalUrl.startsWith('http')) {
      finalUrl = '$apiBase${finalUrl.startsWith('/') ? '' : '/'}$finalUrl';
    }
    
    finalUrl = finalUrl.replaceFirst('://', '@@@').replaceAll('//', '/').replaceFirst('@@@', '://');
    
    // Jeśli to link WebService, upewnij się, że ma klucz, ale tylko jeśli to NIE jest bezpośredni link do pliku jpg/png
    if (finalUrl.contains('/api/images/') && !finalUrl.toLowerCase().contains('.jpg')) {
      if (!finalUrl.contains('ws_key=')) {
        finalUrl += '${finalUrl.contains('?') ? '&' : '?'}ws_key=${ApiConfig.apiKey}';
      }
    }
    
    return finalUrl;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic field) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is Map) {
        if (field['language'] != null) {
          var lang = field['language'];
          if (lang is List && lang.isNotEmpty) return (lang[0]['value'] ?? '').toString();
          if (lang is Map) return (lang['value'] ?? '').toString();
        }
        return (field['value'] ?? '').toString();
      }
      return field.toString();
    }

    double parsePrice(dynamic p) {
      if (p == null) return 0.0;
      if (p is num) return p.toDouble();
      // Obsługa formatów "123,45" i "123.45"
      final clean = p.toString().replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }

    final id = int.tryParse(json['id'].toString()) ?? 0;
    
    // Senior Fix: Priorytetyzacja obrazów publicznych nad WebService (unikamy 400 Bad Request)
    List<String> imagesList = [];
    
    // 1. Sprawdzamy czy mamy gotowe publiczne linki (z modułu pharosapi)
    if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imagesList.add(json['image'].toString());
    } else if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      imagesList.addAll((json['images'] as List).map((e) => e.toString()));
    } 
    
    // 2. Jeśli nadal pusto, próbujemy image_ws (WebService)
    if (imagesList.isEmpty && json['image_ws'] != null) {
      imagesList.add(json['image_ws'].toString());
    }

    // 3. Fallback do struktury PrestaShop (id_default_image)
    if (imagesList.isEmpty && json['id_default_image'] != null && json['id_default_image'] != '0') {
      final imgId = json['id_default_image'].toString();
      final apiBase = ApiConfig.baseUrl.split('/api').first;
      imagesList.add('$apiBase/api/images/products/$id/$imgId');
    }

    // Stabilizacja wszystkich URLi
    imagesList = imagesList.map((url) => _stabilizeImageUrl(url, id)).where((url) => url.isNotEmpty).toList();

    double price = parsePrice(json['price']);
    // Jeśli cena netto (brak sformatowanej), dodaj podatek
    if (json['price_formatted'] == null && !json.containsKey('discount_percentage')) {
      price = price * 1.23;
    }

    return ProductModel(
      id: id,
      name: parseString(json['name']),
      description: parseString(json['description'] ?? json['description_short']),
      price: price,
      priceOld: json['price_old'] != null ? parsePrice(json['price_old']) : null,
      discountPercentage: int.tryParse(json['discount_percentage']?.toString() ?? ''),
      images: imagesList,
      imageUrl: imagesList.isNotEmpty ? imagesList.first : '',
      stockQuantity: int.tryParse((json['stock'] ?? json['quantity'] ?? '0').toString()) ?? 0,
      allowOutOfStockOrders: json['out_of_stock'] == '1' || json['out_of_stock'] == '2' || (int.tryParse(json['stock'].toString() ?? '0') ?? 0) > 0,
      availableForOrder: json['available_for_order'] == true || json['available_for_order'] == '1' || json['available_for_order'] == 'active',
      minimalQuantity: int.tryParse(json['minimal_quantity']?.toString() ?? '1') ?? 1,
      reference: json['reference'] ?? '',
      manufacturerName: json['manufacturer_name'] ?? '',
      availableNowLabel: parseString(json['available_now']),
      availableLaterLabel: parseString(json['available_later']),
    );
  }

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
