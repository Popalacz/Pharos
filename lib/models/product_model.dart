import '../core/api/api_config.dart';

class Product {
  final int id;
  final String name;
  final String price;
  final String? idImage;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.idImage,
    this.description,
  });

  bool get hasImageUrl =>
      idImage != null && idImage!.isNotEmpty;

  String get imageUrl {
    if (!hasImageUrl) {
      return '';
    }

    return '${ApiConfig.baseUrl}/images/products/$id/$idImage?ws_key=${ApiConfig.apiKey}';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String nameValue = '';
    final Object? nameField = json['name'];

    if (nameField is Map) {
      final Object? lang = nameField['language'];

      if (lang is List && lang.isNotEmpty) {
        nameValue = (lang[0] as Map)['value']?.toString() ?? '';
      } else if (lang is Map) {
        nameValue = lang['value']?.toString() ?? '';
      }
    } else if (nameField is List && nameField.isNotEmpty) {
      nameValue = (nameField[0] as Map)['value']?.toString() ?? '';
    } else {
      nameValue = nameField?.toString() ?? '';
    }

    String? descriptionValue;
    final Object? descriptionField = json['description'];

    if (descriptionField is Map) {
      final Object? lang = descriptionField['language'];

      if (lang is List && lang.isNotEmpty) {
        descriptionValue = (lang[0] as Map)['value']?.toString();
      } else if (lang is Map) {
        descriptionValue = lang['value']?.toString();
      }
    } else if (descriptionField is List && descriptionField.isNotEmpty) {
      descriptionValue = (descriptionField[0] as Map)['value']?.toString();
    } else if (descriptionField is String) {
      descriptionValue = descriptionField;
    }

    if (descriptionValue != null && descriptionValue.trim().isEmpty) {
      descriptionValue = null;
    }

    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: nameValue,
      price: double.tryParse(json['price'].toString())?.toStringAsFixed(2) ?? '0.00',
      idImage: json['id_default_image']?.toString(),
      description: descriptionValue,
    );
  }
}