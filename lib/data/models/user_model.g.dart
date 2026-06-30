// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: const DefensiveIntConverter().fromJson(json['id']),
      email: json['email'] == null
          ? ''
          : const DefensiveStringConverter().fromJson(json['email']),
      firstname: json['firstname'] == null
          ? ''
          : const DefensiveStringConverter().fromJson(json['firstname']),
      lastname: json['lastname'] == null
          ? ''
          : const DefensiveStringConverter().fromJson(json['lastname']),
      photoUrl: json['photo_url'] as String?,
      birthday: json['birthday'] as String?,
      newsletter: json['newsletter'] == null
          ? false
          : const DefensiveBoolConverter().fromJson(json['newsletter']),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': const DefensiveIntConverter().toJson(instance.id),
      'email': const DefensiveStringConverter().toJson(instance.email),
      'firstname': const DefensiveStringConverter().toJson(instance.firstname),
      'lastname': const DefensiveStringConverter().toJson(instance.lastname),
      'photo_url': instance.photoUrl,
      'birthday': instance.birthday,
      'newsletter': const DefensiveBoolConverter().toJson(instance.newsletter),
    };
