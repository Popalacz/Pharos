class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isAvailable = true,
  });

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
