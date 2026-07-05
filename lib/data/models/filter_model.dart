class FilterGroup {
  final String id; // np. 'category', 'price', 'color', 'size'
  final String name; // np. 'Kolor', 'Rozmiar'
  final List<FilterValue> values;
  final bool allowMultiple;

  FilterGroup({
    required this.id,
    required this.name,
    required this.values,
    this.allowMultiple = true,
  });

  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    return FilterGroup(
      id: json['id'].toString(),
      name: json['name'],
      allowMultiple: json['allow_multiple'] ?? true,
      values: (json['values'] as List).map((v) => FilterValue.fromJson(v)).toList(),
    );
  }
}

class FilterValue {
  final String id;
  final String name;
  final String? colorHex; // Dla filtrów typu kolor
  bool isSelected;

  FilterValue({
    required this.id,
    required this.name,
    this.colorHex,
    this.isSelected = false,
  });

  factory FilterValue.fromJson(Map<String, dynamic> json) {
    return FilterValue(
      id: json['id'].toString(),
      name: json['name'],
      colorHex: _normalizeColor(json['color']),
    );
  }

  static String? _normalizeColor(dynamic rawColor) {
    if (rawColor == null) {
      return null;
    }

    final color = rawColor.toString().trim();
    if (color.isEmpty) {
      return null;
    }

    if (color.startsWith('#')) {
      return color;
    }

    return '#$color';
  }
}
