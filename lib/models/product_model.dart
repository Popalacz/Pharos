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

  bool get hasImageUrl {
    if (idImage == null || idImage!.isEmpty) {
      return false;
    }

    final int? parsed = int.tryParse(idImage!);

    if (parsed != null && parsed <= 0) {
      return false;
    }

    return true;
  }

  String get imageUrl {
    if (!hasImageUrl) {
      return '';
    }

    return '${ApiConfig.baseUrl}/images/products/$id/$idImage?ws_key=${ApiConfig.apiKey}';
  }

  /// PrestaShop WS returns either a plain string or multilingual `{ "language": ... }`.
  static String _readTextField(Map<String, dynamic> json, String key) {
    final Object? field = json[key];

    if (field is Map) {
      final Object? lang = field['language'];

      if (lang is List && lang.isNotEmpty) {
        return (lang[0] as Map)['value']?.toString() ?? '';
      }

      if (lang is Map) {
        return lang['value']?.toString() ?? '';
      }
    } else if (field is List && field.isNotEmpty) {
      return (field[0] as Map)['value']?.toString() ?? '';
    } else if (field is String) {
      return field;
    } else if (field != null) {
      return field.toString();
    }

    return '';
  }

  static String? _readOptionalTextField(Map<String, dynamic> json, String key) {
    final String value = _readTextField(json, key).trim();

    if (value.isEmpty) {
      return null;
    }

    return value;
  }

  static String? _resolveCoverImageId(Map<String, dynamic> json) {
    final int? fromDefault = int.tryParse(json['id_default_image']?.toString() ?? '');

    if (fromDefault != null && fromDefault > 0) {
      return fromDefault.toString();
    }

    final Object? associations = json['associations'];

    if (associations is! Map) {
      return null;
    }

    final Object? imagesNode = associations['images'];

    if (imagesNode is! List || imagesNode.isEmpty) {
      return null;
    }

    final Object? first = imagesNode.first;

    if (first is! Map) {
      return null;
    }

    final int? imageId = int.tryParse(first['id']?.toString() ?? '');

    if (imageId != null && imageId > 0) {
      return imageId.toString();
    }

    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final String nameValue = _readTextField(json, 'name').trim();
    String? descriptionValue = _readOptionalTextField(json, 'description');

    if (descriptionValue == null) {
      descriptionValue = _readOptionalTextField(json, 'description_short');
    }

    final String? coverImageId = _resolveCoverImageId(json);

    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: nameValue,
      price: double.tryParse(json['price'].toString())?.toStringAsFixed(2) ?? '0.00',
      idImage: coverImageId,
      description: descriptionValue,
    );
  }
}
