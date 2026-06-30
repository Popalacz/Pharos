// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) {
  return _CategoryModel.fromJson(json);
}

/// @nodoc
mixin _$CategoryModel {
  @DefensiveIntConverter()
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  @JsonKey(name: 'name')
  String get name => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  @JsonKey(name: 'description')
  String get description => throw _privateConstructorUsedError;
  @DefensiveNullableIntConverter()
  @JsonKey(name: 'id_parent')
  int? get idParent => throw _privateConstructorUsedError;

  /// Serializes this CategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryModelCopyWith<CategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryModelCopyWith<$Res> {
  factory $CategoryModelCopyWith(
    CategoryModel value,
    $Res Function(CategoryModel) then,
  ) = _$CategoryModelCopyWithImpl<$Res, CategoryModel>;
  @useResult
  $Res call({
    @DefensiveIntConverter() @JsonKey(name: 'id') int id,
    @DefensiveStringConverter() @JsonKey(name: 'name') String name,
    @DefensiveStringConverter()
    @JsonKey(name: 'description')
    String description,
    @DefensiveNullableIntConverter() @JsonKey(name: 'id_parent') int? idParent,
  });
}

/// @nodoc
class _$CategoryModelCopyWithImpl<$Res, $Val extends CategoryModel>
    implements $CategoryModelCopyWith<$Res> {
  _$CategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? idParent = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            idParent: freezed == idParent
                ? _value.idParent
                : idParent // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryModelImplCopyWith<$Res>
    implements $CategoryModelCopyWith<$Res> {
  factory _$$CategoryModelImplCopyWith(
    _$CategoryModelImpl value,
    $Res Function(_$CategoryModelImpl) then,
  ) = __$$CategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @DefensiveIntConverter() @JsonKey(name: 'id') int id,
    @DefensiveStringConverter() @JsonKey(name: 'name') String name,
    @DefensiveStringConverter()
    @JsonKey(name: 'description')
    String description,
    @DefensiveNullableIntConverter() @JsonKey(name: 'id_parent') int? idParent,
  });
}

/// @nodoc
class __$$CategoryModelImplCopyWithImpl<$Res>
    extends _$CategoryModelCopyWithImpl<$Res, _$CategoryModelImpl>
    implements _$$CategoryModelImplCopyWith<$Res> {
  __$$CategoryModelImplCopyWithImpl(
    _$CategoryModelImpl _value,
    $Res Function(_$CategoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? idParent = freezed,
  }) {
    return _then(
      _$CategoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        idParent: freezed == idParent
            ? _value.idParent
            : idParent // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryModelImpl implements _CategoryModel {
  const _$CategoryModelImpl({
    @DefensiveIntConverter() @JsonKey(name: 'id') required this.id,
    @DefensiveStringConverter() @JsonKey(name: 'name') required this.name,
    @DefensiveStringConverter()
    @JsonKey(name: 'description')
    this.description = '',
    @DefensiveNullableIntConverter() @JsonKey(name: 'id_parent') this.idParent,
  });

  factory _$CategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryModelImplFromJson(json);

  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'id')
  final int id;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'name')
  final String name;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'description')
  final String description;
  @override
  @DefensiveNullableIntConverter()
  @JsonKey(name: 'id_parent')
  final int? idParent;

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, description: $description, idParent: $idParent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.idParent, idParent) ||
                other.idParent == idParent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, idParent);

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryModelImplCopyWith<_$CategoryModelImpl> get copyWith =>
      __$$CategoryModelImplCopyWithImpl<_$CategoryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryModelImplToJson(this);
  }
}

abstract class _CategoryModel implements CategoryModel {
  const factory _CategoryModel({
    @DefensiveIntConverter() @JsonKey(name: 'id') required final int id,
    @DefensiveStringConverter()
    @JsonKey(name: 'name')
    required final String name,
    @DefensiveStringConverter()
    @JsonKey(name: 'description')
    final String description,
    @DefensiveNullableIntConverter()
    @JsonKey(name: 'id_parent')
    final int? idParent,
  }) = _$CategoryModelImpl;

  factory _CategoryModel.fromJson(Map<String, dynamic> json) =
      _$CategoryModelImpl.fromJson;

  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'id')
  int get id;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'name')
  String get name;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'description')
  String get description;
  @override
  @DefensiveNullableIntConverter()
  @JsonKey(name: 'id_parent')
  int? get idParent;

  /// Create a copy of CategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryModelImplCopyWith<_$CategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
