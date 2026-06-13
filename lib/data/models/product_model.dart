class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stockQuantity;
  final bool allowOutOfStockOrders;
  final int minimalQuantity;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.stockQuantity = 0,
    this.allowOutOfStockOrders = false,
    this.minimalQuantity = 1,
  });

  bool get isAvailable => stockQuantity >= minimalQuantity || allowOutOfStockOrders;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Pomocnicza funkcja do wyciągania zlokalizowanych wartości z formatu PrestaShop
    String getLocalizedValue(dynamic field) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is Map && field['language'] != null) {
        var languages = field['language'];
        if (languages is List && languages.isNotEmpty) {
          return (languages[0]['value'] ?? '').toString();
        }
      }
      return field.toString();
    }

    return ProductModel(
      id: int.parse(json['id'].toString()),
      name: getLocalizedValue(json['name']),
      description: getLocalizedValue(json['description']),
      price: double.parse(json['price'].toString()),
      stockQuantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      allowOutOfStockOrders: json['out_of_stock'] == '1' || json['out_of_stock'] == '2',
      minimalQuantity: int.tryParse(json['minimal_quantity']?.toString() ?? '1') ?? 1,
      imageUrl: json['id_default_image'] != null 
          ? 'https://pharos-shop.pl/api/images/products/${json['id']}/${json['id_default_image']}' 
          : 'https://via.placeholder.com/300',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
  };
}
