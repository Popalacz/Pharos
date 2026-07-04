import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pharos/core/api/api_config.dart';
import 'converters/defensive_json_converters.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    @DefensiveIntConverter() @JsonKey(name: 'id') required int id,
    @DefensiveStringConverter() @JsonKey(name: 'name') required String name,
    @DefensiveStringConverter() @JsonKey(name: 'description') @Default('') String description,
    @DefensiveNullableIntConverter() @JsonKey(name: 'id_parent') int? idParent,
    @DefensiveStringConverter() @JsonKey(name: 'image') @Default('') String imageUrl,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);
}

extension CategoryModelParsing on CategoryModel {
  static String parseLocalizedName(Map<String, dynamic> json) {
    return const DefensiveStringConverter().fromJson(json['name']);
  }
}
