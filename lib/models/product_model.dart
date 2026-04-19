import '../core/api/api_config.dart';

class Product {
  final int id;
  final String name;
  final String price;
  final String? idImage; // To pole musi tu być!

  Product({
    required this.id, 
    required this.name, 
    required this.price, 
    this.idImage,
  });


  String get imageUrl => 
      '${ApiConfig.baseUrl}/images/products/$id/$idImage?ws_key=${ApiConfig.apiKey}';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'] is List ? json['name'][0]['value'] : json['name'].toString(),
      price: double.parse(json['price'].toString()).toStringAsFixed(2),
      idImage: json['id_default_image']?.toString(), // Mapujemy id_default_image z API na idImage
    );
  }
}