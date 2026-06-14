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
    String getLocalizedValue(dynamic field) {
      if (field == null) return '';
      if (field is String) return field;
      if (field is List && field.isNotEmpty) {
        return (field[0]['value'] ?? '').toString();
      }
      if (field is Map && field['language'] != null) {
        var languages = field['language'];
        if (languages is List && languages.isNotEmpty) {
          return (languages[0]['value'] ?? '').toString();
        }
      }
      return field.toString();
    }

    return CategoryModel(
      id: int.parse(json['id'].toString()),
      name: getLocalizedValue(json['name']),
      description: getLocalizedValue(json['description']),
      idParent: json['id_parent'] != null ? int.parse(json['id_parent'].toString()) : null,
    );
  }
}
