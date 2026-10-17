import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters/defensive_json_converters.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @DefensiveIntConverter() required int id,
    @DefensiveStringConverter() @Default('') String email,
    @DefensiveStringConverter() @Default('') String firstname,
    @DefensiveStringConverter() @Default('') String lastname,
    @JsonKey(name: 'photo_url') String? photoUrl,
    String? birthday,
    @DefensiveBoolConverter() @Default(false) bool newsletter,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  String get displayName => '$firstname $lastname'.trim();
}
