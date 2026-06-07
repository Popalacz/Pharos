import '../core/api/api_config.dart';

class Product {
  final int id;
  final String name;
  final String price;
  final String? idImage;
  final List<String> galleryImageIds;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.idImage,
    this.galleryImageIds = const <String>[],
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

    return imageUrlForImageId(idImage!);
  }

  /// PrestaShop WS image URL: `/api/images/products/{productId}/{imageId}`.
  String imageUrlForImageId(String imageId) {
    return '${ApiConfig.baseUrl}/images/products/$id/$imageId?ws_key=${ApiConfig.apiKey}';
  }

  /// Ordered image ids (cover first when known). Empty when the product has no images.
  List<String> get resolvedGalleryImageIds {
    if (galleryImageIds.isNotEmpty) {
      return galleryImageIds;
    }

    if (hasImageUrl && idImage != null) {
      return <String>[idImage!];
    }

    return const <String>[];
  }

  bool get hasMultipleGalleryImages => resolvedGalleryImageIds.length > 1;

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

  /// All product image ids from WS (`associations.images`), with cover image moved to index 0.
  static List<String> _galleryIdsFromJson(Map<String, dynamic> json, String? coverImageId) {
    final List<String> fromAssociation = <String>[];
    final Object? associations = json['associations'];

    if (associations is Map) {
      final Object? imagesNode = associations['images'];

      if (imagesNode is List<dynamic>) {
        for (final Object? item in imagesNode) {
          if (item is! Map) {
            continue;
          }

          final int? imageId = int.tryParse(item['id']?.toString() ?? '');

          if (imageId != null && imageId > 0) {
            fromAssociation.add(imageId.toString());
          }
        }
      }
    }

    final List<String> uniqueAssociation = _uniqueImageIdsInOrder(fromAssociation);

    if (uniqueAssociation.isEmpty) {
      final int? coverParsed = int.tryParse(coverImageId ?? '');

      if (coverParsed != null && coverParsed > 0) {
        return <String>[coverImageId!];
      }

      return const <String>[];
    }

    if (coverImageId == null) {
      return uniqueAssociation;
    }

    final int? coverParsed = int.tryParse(coverImageId);

    if (coverParsed == null || coverParsed <= 0) {
      return uniqueAssociation;
    }

    final List<String> reordered = List<String>.from(uniqueAssociation);

    if (reordered.remove(coverImageId)) {
      reordered.insert(0, coverImageId);
    }

    return reordered;
  }

  static List<String> _uniqueImageIdsInOrder(List<String> imageIds) {
    final Set<String> seenIds = <String>{};
    final List<String> uniqueOrdered = <String>[];

    for (final String imageId in imageIds) {
      if (seenIds.add(imageId)) {
        uniqueOrdered.add(imageId);
      }
    }

    return uniqueOrdered;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final String nameValue = _readTextField(json, 'name').trim();
    String? descriptionValue = _readOptionalTextField(json, 'description');

    descriptionValue ??= _readOptionalTextField(json, 'description_short');

    final String? coverImageId = _resolveCoverImageId(json);
    final List<String> galleryIds = _galleryIdsFromJson(json, coverImageId);

    return Product(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: nameValue,
      price: double.tryParse(json['price'].toString())?.toStringAsFixed(2) ?? '0.00',
      idImage: coverImageId,
      galleryImageIds: galleryIds,
      description: descriptionValue,
    );
  }
}
