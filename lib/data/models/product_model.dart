class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> images; // Zmienione na listę zdjęć
  final String imageUrl; // Główne zdjęcie
  final int stockQuantity;
  final bool allowOutOfStockOrders;
  final int minimalQuantity;
  final String reference;
  final String manufacturerName;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.imageUrl,
    required this.stockQuantity,
    this.allowOutOfStockOrders = false,
    this.minimalQuantity = 1,
    this.reference = '',
    this.manufacturerName = '',
  });

  bool get isAvailable => stockQuantity >= minimalQuantity || allowOutOfStockOrders;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String parseLocalized(dynamic field) {
      if (field == null) return '';
      if (field is String) return field.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ''); // Czyścimy HTML
      if (field is List && field.isNotEmpty) {
        return (field[0]['value'] ?? field[0].toString()).toString().replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '');
      }
      return field.toString().replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '');
    }

    final String productId = json['id'].toString();
    final String apiKey = 'PHAROS00008RLIS6EBBLYEYGUPP1XPFA';
    
    // Budowanie galerii zdjęć z asocjacji PrestaShop
    List<String> imagesList = [];
    if (json['associations']?['images'] != null) {
      final imgs = json['associations']['images'] as List;
      for (var img in imgs) {
        imagesList.add('https://pharos-api.tech/api/images/products/$productId/${img['id']}?ws_key=$apiKey');
      }
    }
    
    // Jeśli brak galerii, użyj domyślnego
    if (imagesList.isEmpty) {
      final String imageId = json['id_default_image']?.toString() ?? productId;
      imagesList.add('https://pharos-api.tech/api/images/products/$productId/$imageId?ws_key=$apiKey');
    }

    return ProductModel(
      id: int.parse(productId),
      name: parseLocalized(json['name']),
      description: parseLocalized(json['description']),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      images: imagesList,
      imageUrl: imagesList.first,
      stockQuantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      allowOutOfStockOrders: json['out_of_stock'] == '1' || json['out_of_stock'] == '2',
      minimalQuantity: int.tryParse(json['minimal_quantity']?.toString() ?? '1') ?? 1,
      reference: json['reference']?.toString() ?? '',
      manufacturerName: json['manufacturer_name']?.toString() ?? '',
    );
  }
}
