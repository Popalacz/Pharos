class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int? idParent;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.idParent,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String parseLocalized(dynamic field) {
      if (field == null) return '';
      String rawValue = '';
      
      if (field is String) {
        rawValue = field;
      } else if (field is List && field.isNotEmpty) {
        rawValue = (field[0] is Map) ? (field[0]['value'] ?? '').toString() : field[0].toString();
      } else if (field is Map) {
        if (field['language'] != null) {
          var lang = field['language'];
          if (lang is List && lang.isNotEmpty) rawValue = (lang[0]['value'] ?? '').toString();
          else if (lang is Map) rawValue = (lang['value'] ?? '').toString();
        } else {
          rawValue = (field['value'] ?? field['name'] ?? '').toString();
        }
      } else {
        rawValue = field.toString();
      }
      return rawValue.replaceAll(RegExp(r'<[^>]*>|&nbsp;|&amp;|&quot;'), ' ').trim();
    }

    return CategoryModel(
      id: int.parse(json['id'].toString()),
      name: parseLocalized(json['name']),
      description: parseLocalized(json['description']),
      idParent: json['id_parent'] != null ? int.tryParse(json['id_parent'].toString()) : null,
    );
  }
}
