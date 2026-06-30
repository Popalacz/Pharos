// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CartModel _$CartModelFromJson(Map<String, dynamic> json) {
  return _CartModel.fromJson(json);
}

/// @nodoc
mixin _$CartModel {
  @DefensiveIntConverter()
  @JsonKey(name: 'id_cart')
  int get idCart => throw _privateConstructorUsedError;
  @DefensiveDoubleConverter()
  double get total => throw _privateConstructorUsedError;
  @DefensiveDoubleConverter()
  @JsonKey(name: 'total_products')
  double get totalProducts => throw _privateConstructorUsedError;
  @DefensiveDoubleConverter()
  @JsonKey(name: 'total_shipping')
  double get totalShipping => throw _privateConstructorUsedError;
  @DefensiveDoubleConverter()
  @JsonKey(name: 'discount_amount')
  double get discountAmount => throw _privateConstructorUsedError;

  /// Serializes this CartModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartModelCopyWith<CartModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartModelCopyWith<$Res> {
  factory $CartModelCopyWith(CartModel value, $Res Function(CartModel) then) =
      _$CartModelCopyWithImpl<$Res, CartModel>;
  @useResult
  $Res call({
    @DefensiveIntConverter() @JsonKey(name: 'id_cart') int idCart,
    @DefensiveDoubleConverter() double total,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_products')
    double totalProducts,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_shipping')
    double totalShipping,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'discount_amount')
    double discountAmount,
  });
}

/// @nodoc
class _$CartModelCopyWithImpl<$Res, $Val extends CartModel>
    implements $CartModelCopyWith<$Res> {
  _$CartModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idCart = null,
    Object? total = null,
    Object? totalProducts = null,
    Object? totalShipping = null,
    Object? discountAmount = null,
  }) {
    return _then(
      _value.copyWith(
            idCart: null == idCart
                ? _value.idCart
                : idCart // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as double,
            totalProducts: null == totalProducts
                ? _value.totalProducts
                : totalProducts // ignore: cast_nullable_to_non_nullable
                      as double,
            totalShipping: null == totalShipping
                ? _value.totalShipping
                : totalShipping // ignore: cast_nullable_to_non_nullable
                      as double,
            discountAmount: null == discountAmount
                ? _value.discountAmount
                : discountAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CartModelImplCopyWith<$Res>
    implements $CartModelCopyWith<$Res> {
  factory _$$CartModelImplCopyWith(
    _$CartModelImpl value,
    $Res Function(_$CartModelImpl) then,
  ) = __$$CartModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @DefensiveIntConverter() @JsonKey(name: 'id_cart') int idCart,
    @DefensiveDoubleConverter() double total,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_products')
    double totalProducts,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_shipping')
    double totalShipping,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'discount_amount')
    double discountAmount,
  });
}

/// @nodoc
class __$$CartModelImplCopyWithImpl<$Res>
    extends _$CartModelCopyWithImpl<$Res, _$CartModelImpl>
    implements _$$CartModelImplCopyWith<$Res> {
  __$$CartModelImplCopyWithImpl(
    _$CartModelImpl _value,
    $Res Function(_$CartModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? idCart = null,
    Object? total = null,
    Object? totalProducts = null,
    Object? totalShipping = null,
    Object? discountAmount = null,
  }) {
    return _then(
      _$CartModelImpl(
        idCart: null == idCart
            ? _value.idCart
            : idCart // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as double,
        totalProducts: null == totalProducts
            ? _value.totalProducts
            : totalProducts // ignore: cast_nullable_to_non_nullable
                  as double,
        totalShipping: null == totalShipping
            ? _value.totalShipping
            : totalShipping // ignore: cast_nullable_to_non_nullable
                  as double,
        discountAmount: null == discountAmount
            ? _value.discountAmount
            : discountAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartModelImpl implements _CartModel {
  const _$CartModelImpl({
    @DefensiveIntConverter() @JsonKey(name: 'id_cart') this.idCart = 0,
    @DefensiveDoubleConverter() this.total = 0,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_products')
    this.totalProducts = 0,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_shipping')
    this.totalShipping = 0,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'discount_amount')
    this.discountAmount = 0,
  });

  factory _$CartModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartModelImplFromJson(json);

  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'id_cart')
  final int idCart;
  @override
  @JsonKey()
  @DefensiveDoubleConverter()
  final double total;
  @override
  @DefensiveDoubleConverter()
  @JsonKey(name: 'total_products')
  final double totalProducts;
  @override
  @DefensiveDoubleConverter()
  @JsonKey(name: 'total_shipping')
  final double totalShipping;
  @override
  @DefensiveDoubleConverter()
  @JsonKey(name: 'discount_amount')
  final double discountAmount;

  @override
  String toString() {
    return 'CartModel(idCart: $idCart, total: $total, totalProducts: $totalProducts, totalShipping: $totalShipping, discountAmount: $discountAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartModelImpl &&
            (identical(other.idCart, idCart) || other.idCart == idCart) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalProducts, totalProducts) ||
                other.totalProducts == totalProducts) &&
            (identical(other.totalShipping, totalShipping) ||
                other.totalShipping == totalShipping) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    idCart,
    total,
    totalProducts,
    totalShipping,
    discountAmount,
  );

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartModelImplCopyWith<_$CartModelImpl> get copyWith =>
      __$$CartModelImplCopyWithImpl<_$CartModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartModelImplToJson(this);
  }
}

abstract class _CartModel implements CartModel {
  const factory _CartModel({
    @DefensiveIntConverter() @JsonKey(name: 'id_cart') final int idCart,
    @DefensiveDoubleConverter() final double total,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_products')
    final double totalProducts,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'total_shipping')
    final double totalShipping,
    @DefensiveDoubleConverter()
    @JsonKey(name: 'discount_amount')
    final double discountAmount,
  }) = _$CartModelImpl;

  factory _CartModel.fromJson(Map<String, dynamic> json) =
      _$CartModelImpl.fromJson;

  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'id_cart')
  int get idCart;
  @override
  @DefensiveDoubleConverter()
  double get total;
  @override
  @DefensiveDoubleConverter()
  @JsonKey(name: 'total_products')
  double get totalProducts;
  @override
  @DefensiveDoubleConverter()
  @JsonKey(name: 'total_shipping')
  double get totalShipping;
  @override
  @DefensiveDoubleConverter()
  @JsonKey(name: 'discount_amount')
  double get discountAmount;

  /// Create a copy of CartModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartModelImplCopyWith<_$CartModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
