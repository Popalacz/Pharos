// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductModel {
  @DefensiveIntConverter()
  int get id => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  String get name => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  String get description => throw _privateConstructorUsedError;
  @DefensiveDoubleConverter()
  double get price => throw _privateConstructorUsedError;
  @DefensiveNullableDoubleConverter()
  @JsonKey(name: 'price_old')
  double? get priceOld => throw _privateConstructorUsedError;
  @DefensiveNullableIntConverter()
  @JsonKey(name: 'discount_percentage')
  int? get discountPercentage => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'imageUrl')
  String get imageUrl => throw _privateConstructorUsedError;
  @DefensiveIntConverter()
  @JsonKey(name: 'stock')
  int get stockQuantity => throw _privateConstructorUsedError;
  @DefensiveBoolConverter()
  @JsonKey(name: 'out_of_stock')
  bool get allowOutOfStockOrders => throw _privateConstructorUsedError;
  @DefensiveBoolConverter()
  @JsonKey(name: 'available_for_order')
  bool get availableForOrder => throw _privateConstructorUsedError;
  @DefensiveIntConverter()
  @JsonKey(name: 'minimal_quantity')
  int get minimalQuantity => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  String get reference => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  @JsonKey(name: 'manufacturer_name')
  String get manufacturerName => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  @JsonKey(name: 'available_now')
  String get availableNowLabel => throw _privateConstructorUsedError;
  @DefensiveStringConverter()
  @JsonKey(name: 'available_later')
  String get availableLaterLabel => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
    ProductModel value,
    $Res Function(ProductModel) then,
  ) = _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call({
    @DefensiveIntConverter() int id,
    @DefensiveStringConverter() String name,
    @DefensiveStringConverter() String description,
    @DefensiveDoubleConverter() double price,
    @DefensiveNullableDoubleConverter()
    @JsonKey(name: 'price_old')
    double? priceOld,
    @DefensiveNullableIntConverter()
    @JsonKey(name: 'discount_percentage')
    int? discountPercentage,
    List<String> images,
    @JsonKey(name: 'imageUrl') String imageUrl,
    @DefensiveIntConverter() @JsonKey(name: 'stock') int stockQuantity,
    @DefensiveBoolConverter()
    @JsonKey(name: 'out_of_stock')
    bool allowOutOfStockOrders,
    @DefensiveBoolConverter()
    @JsonKey(name: 'available_for_order')
    bool availableForOrder,
    @DefensiveIntConverter()
    @JsonKey(name: 'minimal_quantity')
    int minimalQuantity,
    @DefensiveStringConverter() String reference,
    @DefensiveStringConverter()
    @JsonKey(name: 'manufacturer_name')
    String manufacturerName,
    @DefensiveStringConverter()
    @JsonKey(name: 'available_now')
    String availableNowLabel,
    @DefensiveStringConverter()
    @JsonKey(name: 'available_later')
    String availableLaterLabel,
  });
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? priceOld = freezed,
    Object? discountPercentage = freezed,
    Object? images = null,
    Object? imageUrl = null,
    Object? stockQuantity = null,
    Object? allowOutOfStockOrders = null,
    Object? availableForOrder = null,
    Object? minimalQuantity = null,
    Object? reference = null,
    Object? manufacturerName = null,
    Object? availableNowLabel = null,
    Object? availableLaterLabel = null,
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
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            priceOld: freezed == priceOld
                ? _value.priceOld
                : priceOld // ignore: cast_nullable_to_non_nullable
                      as double?,
            discountPercentage: freezed == discountPercentage
                ? _value.discountPercentage
                : discountPercentage // ignore: cast_nullable_to_non_nullable
                      as int?,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            stockQuantity: null == stockQuantity
                ? _value.stockQuantity
                : stockQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            allowOutOfStockOrders: null == allowOutOfStockOrders
                ? _value.allowOutOfStockOrders
                : allowOutOfStockOrders // ignore: cast_nullable_to_non_nullable
                      as bool,
            availableForOrder: null == availableForOrder
                ? _value.availableForOrder
                : availableForOrder // ignore: cast_nullable_to_non_nullable
                      as bool,
            minimalQuantity: null == minimalQuantity
                ? _value.minimalQuantity
                : minimalQuantity // ignore: cast_nullable_to_non_nullable
                      as int,
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String,
            manufacturerName: null == manufacturerName
                ? _value.manufacturerName
                : manufacturerName // ignore: cast_nullable_to_non_nullable
                      as String,
            availableNowLabel: null == availableNowLabel
                ? _value.availableNowLabel
                : availableNowLabel // ignore: cast_nullable_to_non_nullable
                      as String,
            availableLaterLabel: null == availableLaterLabel
                ? _value.availableLaterLabel
                : availableLaterLabel // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
    _$ProductModelImpl value,
    $Res Function(_$ProductModelImpl) then,
  ) = __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @DefensiveIntConverter() int id,
    @DefensiveStringConverter() String name,
    @DefensiveStringConverter() String description,
    @DefensiveDoubleConverter() double price,
    @DefensiveNullableDoubleConverter()
    @JsonKey(name: 'price_old')
    double? priceOld,
    @DefensiveNullableIntConverter()
    @JsonKey(name: 'discount_percentage')
    int? discountPercentage,
    List<String> images,
    @JsonKey(name: 'imageUrl') String imageUrl,
    @DefensiveIntConverter() @JsonKey(name: 'stock') int stockQuantity,
    @DefensiveBoolConverter()
    @JsonKey(name: 'out_of_stock')
    bool allowOutOfStockOrders,
    @DefensiveBoolConverter()
    @JsonKey(name: 'available_for_order')
    bool availableForOrder,
    @DefensiveIntConverter()
    @JsonKey(name: 'minimal_quantity')
    int minimalQuantity,
    @DefensiveStringConverter() String reference,
    @DefensiveStringConverter()
    @JsonKey(name: 'manufacturer_name')
    String manufacturerName,
    @DefensiveStringConverter()
    @JsonKey(name: 'available_now')
    String availableNowLabel,
    @DefensiveStringConverter()
    @JsonKey(name: 'available_later')
    String availableLaterLabel,
  });
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
    _$ProductModelImpl _value,
    $Res Function(_$ProductModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? price = null,
    Object? priceOld = freezed,
    Object? discountPercentage = freezed,
    Object? images = null,
    Object? imageUrl = null,
    Object? stockQuantity = null,
    Object? allowOutOfStockOrders = null,
    Object? availableForOrder = null,
    Object? minimalQuantity = null,
    Object? reference = null,
    Object? manufacturerName = null,
    Object? availableNowLabel = null,
    Object? availableLaterLabel = null,
  }) {
    return _then(
      _$ProductModelImpl(
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
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        priceOld: freezed == priceOld
            ? _value.priceOld
            : priceOld // ignore: cast_nullable_to_non_nullable
                  as double?,
        discountPercentage: freezed == discountPercentage
            ? _value.discountPercentage
            : discountPercentage // ignore: cast_nullable_to_non_nullable
                  as int?,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        stockQuantity: null == stockQuantity
            ? _value.stockQuantity
            : stockQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        allowOutOfStockOrders: null == allowOutOfStockOrders
            ? _value.allowOutOfStockOrders
            : allowOutOfStockOrders // ignore: cast_nullable_to_non_nullable
                  as bool,
        availableForOrder: null == availableForOrder
            ? _value.availableForOrder
            : availableForOrder // ignore: cast_nullable_to_non_nullable
                  as bool,
        minimalQuantity: null == minimalQuantity
            ? _value.minimalQuantity
            : minimalQuantity // ignore: cast_nullable_to_non_nullable
                  as int,
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String,
        manufacturerName: null == manufacturerName
            ? _value.manufacturerName
            : manufacturerName // ignore: cast_nullable_to_non_nullable
                  as String,
        availableNowLabel: null == availableNowLabel
            ? _value.availableNowLabel
            : availableNowLabel // ignore: cast_nullable_to_non_nullable
                  as String,
        availableLaterLabel: null == availableLaterLabel
            ? _value.availableLaterLabel
            : availableLaterLabel // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ProductModelImpl extends _ProductModel {
  const _$ProductModelImpl({
    @DefensiveIntConverter() required this.id,
    @DefensiveStringConverter() this.name = '',
    @DefensiveStringConverter() this.description = '',
    @DefensiveDoubleConverter() this.price = 0,
    @DefensiveNullableDoubleConverter()
    @JsonKey(name: 'price_old')
    this.priceOld,
    @DefensiveNullableIntConverter()
    @JsonKey(name: 'discount_percentage')
    this.discountPercentage,
    final List<String> images = const [],
    @JsonKey(name: 'imageUrl') this.imageUrl = '',
    @DefensiveIntConverter() @JsonKey(name: 'stock') this.stockQuantity = 0,
    @DefensiveBoolConverter()
    @JsonKey(name: 'out_of_stock')
    this.allowOutOfStockOrders = false,
    @DefensiveBoolConverter()
    @JsonKey(name: 'available_for_order')
    this.availableForOrder = true,
    @DefensiveIntConverter()
    @JsonKey(name: 'minimal_quantity')
    this.minimalQuantity = 1,
    @DefensiveStringConverter() this.reference = '',
    @DefensiveStringConverter()
    @JsonKey(name: 'manufacturer_name')
    this.manufacturerName = '',
    @DefensiveStringConverter()
    @JsonKey(name: 'available_now')
    this.availableNowLabel = '',
    @DefensiveStringConverter()
    @JsonKey(name: 'available_later')
    this.availableLaterLabel = '',
  }) : _images = images,
       super._();

  @override
  @DefensiveIntConverter()
  final int id;
  @override
  @JsonKey()
  @DefensiveStringConverter()
  final String name;
  @override
  @JsonKey()
  @DefensiveStringConverter()
  final String description;
  @override
  @JsonKey()
  @DefensiveDoubleConverter()
  final double price;
  @override
  @DefensiveNullableDoubleConverter()
  @JsonKey(name: 'price_old')
  final double? priceOld;
  @override
  @DefensiveNullableIntConverter()
  @JsonKey(name: 'discount_percentage')
  final int? discountPercentage;
  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey(name: 'imageUrl')
  final String imageUrl;
  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'stock')
  final int stockQuantity;
  @override
  @DefensiveBoolConverter()
  @JsonKey(name: 'out_of_stock')
  final bool allowOutOfStockOrders;
  @override
  @DefensiveBoolConverter()
  @JsonKey(name: 'available_for_order')
  final bool availableForOrder;
  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'minimal_quantity')
  final int minimalQuantity;
  @override
  @JsonKey()
  @DefensiveStringConverter()
  final String reference;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'manufacturer_name')
  final String manufacturerName;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'available_now')
  final String availableNowLabel;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'available_later')
  final String availableLaterLabel;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, description: $description, price: $price, priceOld: $priceOld, discountPercentage: $discountPercentage, images: $images, imageUrl: $imageUrl, stockQuantity: $stockQuantity, allowOutOfStockOrders: $allowOutOfStockOrders, availableForOrder: $availableForOrder, minimalQuantity: $minimalQuantity, reference: $reference, manufacturerName: $manufacturerName, availableNowLabel: $availableNowLabel, availableLaterLabel: $availableLaterLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceOld, priceOld) ||
                other.priceOld == priceOld) &&
            (identical(other.discountPercentage, discountPercentage) ||
                other.discountPercentage == discountPercentage) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.stockQuantity, stockQuantity) ||
                other.stockQuantity == stockQuantity) &&
            (identical(other.allowOutOfStockOrders, allowOutOfStockOrders) ||
                other.allowOutOfStockOrders == allowOutOfStockOrders) &&
            (identical(other.availableForOrder, availableForOrder) ||
                other.availableForOrder == availableForOrder) &&
            (identical(other.minimalQuantity, minimalQuantity) ||
                other.minimalQuantity == minimalQuantity) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.manufacturerName, manufacturerName) ||
                other.manufacturerName == manufacturerName) &&
            (identical(other.availableNowLabel, availableNowLabel) ||
                other.availableNowLabel == availableNowLabel) &&
            (identical(other.availableLaterLabel, availableLaterLabel) ||
                other.availableLaterLabel == availableLaterLabel));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    price,
    priceOld,
    discountPercentage,
    const DeepCollectionEquality().hash(_images),
    imageUrl,
    stockQuantity,
    allowOutOfStockOrders,
    availableForOrder,
    minimalQuantity,
    reference,
    manufacturerName,
    availableNowLabel,
    availableLaterLabel,
  );

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);
}

abstract class _ProductModel extends ProductModel {
  const factory _ProductModel({
    @DefensiveIntConverter() required final int id,
    @DefensiveStringConverter() final String name,
    @DefensiveStringConverter() final String description,
    @DefensiveDoubleConverter() final double price,
    @DefensiveNullableDoubleConverter()
    @JsonKey(name: 'price_old')
    final double? priceOld,
    @DefensiveNullableIntConverter()
    @JsonKey(name: 'discount_percentage')
    final int? discountPercentage,
    final List<String> images,
    @JsonKey(name: 'imageUrl') final String imageUrl,
    @DefensiveIntConverter() @JsonKey(name: 'stock') final int stockQuantity,
    @DefensiveBoolConverter()
    @JsonKey(name: 'out_of_stock')
    final bool allowOutOfStockOrders,
    @DefensiveBoolConverter()
    @JsonKey(name: 'available_for_order')
    final bool availableForOrder,
    @DefensiveIntConverter()
    @JsonKey(name: 'minimal_quantity')
    final int minimalQuantity,
    @DefensiveStringConverter() final String reference,
    @DefensiveStringConverter()
    @JsonKey(name: 'manufacturer_name')
    final String manufacturerName,
    @DefensiveStringConverter()
    @JsonKey(name: 'available_now')
    final String availableNowLabel,
    @DefensiveStringConverter()
    @JsonKey(name: 'available_later')
    final String availableLaterLabel,
  }) = _$ProductModelImpl;
  const _ProductModel._() : super._();

  @override
  @DefensiveIntConverter()
  int get id;
  @override
  @DefensiveStringConverter()
  String get name;
  @override
  @DefensiveStringConverter()
  String get description;
  @override
  @DefensiveDoubleConverter()
  double get price;
  @override
  @DefensiveNullableDoubleConverter()
  @JsonKey(name: 'price_old')
  double? get priceOld;
  @override
  @DefensiveNullableIntConverter()
  @JsonKey(name: 'discount_percentage')
  int? get discountPercentage;
  @override
  List<String> get images;
  @override
  @JsonKey(name: 'imageUrl')
  String get imageUrl;
  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'stock')
  int get stockQuantity;
  @override
  @DefensiveBoolConverter()
  @JsonKey(name: 'out_of_stock')
  bool get allowOutOfStockOrders;
  @override
  @DefensiveBoolConverter()
  @JsonKey(name: 'available_for_order')
  bool get availableForOrder;
  @override
  @DefensiveIntConverter()
  @JsonKey(name: 'minimal_quantity')
  int get minimalQuantity;
  @override
  @DefensiveStringConverter()
  String get reference;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'manufacturer_name')
  String get manufacturerName;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'available_now')
  String get availableNowLabel;
  @override
  @DefensiveStringConverter()
  @JsonKey(name: 'available_later')
  String get availableLaterLabel;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
