class CarrierModel {
  final int id;
  final String name;
  final String delay;
  final double price;
  final String? imageUrl;

  CarrierModel({
    required this.id,
    required this.name,
    required this.delay,
    required this.price,
    this.imageUrl,
  });

  factory CarrierModel.fromJson(Map<String, dynamic> json) {
    return CarrierModel(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? 'Kurier',
      delay: json['delay'] ?? '',
      price: double.parse(json['price'] ?? '0.0'),
      imageUrl: json['image_url'], // Pobierane z Twojego modułu pharos_api
    );
  }
}

class PaymentMethodModel {
  final String id; // Nazwa modułu w PrestaShop (np. 'ps_checkout', 'blik')
  final String name;
  final String? description;
  final String? iconUrl;

  PaymentMethodModel({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id_module'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['icon_url'],
    );
  }
}
