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
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Kurier',
      delay: json['delay'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
    );
  }
}

class PaymentMethodModel {
  final String id;
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
      id: json['code'] ?? json['id_module'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['icon_url'],
    );
  }
}
