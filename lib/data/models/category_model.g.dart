// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: const DefensiveIntConverter().fromJson(json['id']),
      name: const DefensiveStringConverter().fromJson(json['name']),
      description: json['description'] == null
          ? ''
          : const DefensiveStringConverter().fromJson(json['description']),
      idParent: const DefensiveNullableIntConverter().fromJson(
        json['id_parent'],
      ),
      imageUrl: json['image'] == null
          ? ''
          : const DefensiveStringConverter().fromJson(json['image']),
    );

Map<String, dynamic> _$$CategoryModelImplToJson(
  _$CategoryModelImpl instance,
) => <String, dynamic>{
  'id': const DefensiveIntConverter().toJson(instance.id),
  'name': const DefensiveStringConverter().toJson(instance.name),
  'description': const DefensiveStringConverter().toJson(instance.description),
  'id_parent': const DefensiveNullableIntConverter().toJson(instance.idParent),
  'image': const DefensiveStringConverter().toJson(instance.imageUrl),
};
