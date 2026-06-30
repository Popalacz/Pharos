import 'package:freezed_annotation/freezed_annotation.dart';

class DefensiveIntConverter implements JsonConverter<int, Object?> {
  const DefensiveIntConverter();

  @override
  int fromJson(Object? json) => int.tryParse('$json') ?? 0;

  @override
  Object toJson(int object) => object;
}

class DefensiveDoubleConverter implements JsonConverter<double, Object?> {
  const DefensiveDoubleConverter();

  @override
  double fromJson(Object? json) {
    if (json == null) return 0.0;
    if (json is num) return json.toDouble();
    final clean = json.toString().replaceAll(',', '.').replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  @override
  Object toJson(double object) => object;
}

class DefensiveStringConverter implements JsonConverter<String, Object?> {
  const DefensiveStringConverter();

  @override
  String fromJson(Object? json) {
    if (json == null) return '';
    if (json is String) return json;
    if (json is Map) {
      if (json['language'] != null) {
        final lang = json['language'];
        if (lang is List && lang.isNotEmpty) {
          return (lang.first is Map ? lang.first['value'] : lang.first)?.toString() ?? '';
        }
        if (lang is Map) return (lang['value'] ?? '').toString();
      }
      return (json['value'] ?? json['name'] ?? '').toString();
    }
    return json.toString();
  }

  @override
  Object toJson(String object) => object;
}

class DefensiveBoolConverter implements JsonConverter<bool, Object?> {
  const DefensiveBoolConverter();

  @override
  bool fromJson(Object? json) {
    if (json == true || json == 1 || json == '1' || json == 'true') return true;
    return false;
  }

  @override
  Object toJson(bool object) => object;
}

class DefensiveNullableDoubleConverter implements JsonConverter<double?, Object?> {
  const DefensiveNullableDoubleConverter();

  @override
  double? fromJson(Object? json) {
    if (json == null) return null;
    return const DefensiveDoubleConverter().fromJson(json);
  }

  @override
  Object? toJson(double? object) => object;
}

class DefensiveNullableIntConverter implements JsonConverter<int?, Object?> {
  const DefensiveNullableIntConverter();

  @override
  int? fromJson(Object? json) {
    if (json == null) return null;
    return int.tryParse('$json');
  }

  @override
  Object? toJson(int? object) => object;
}
