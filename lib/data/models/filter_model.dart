class FilterGroup {
  final String id; // np. 'category', 'price', 'color', 'size'
  final String name; // np. 'Kolor', 'Rozmiar'
  final List<FilterValue> values;

  FilterGroup({required this.id, required this.name, required this.values});

  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    return FilterGroup(
      id: json['id'].toString(),
      name: json['name'],
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
      colorHex: json['color'],
    );
  }
}
