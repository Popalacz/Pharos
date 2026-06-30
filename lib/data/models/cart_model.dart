import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';
import 'converters/defensive_json_converters.dart';

part 'cart_model.freezed.dart';
part 'cart_model.g.dart';

class CartItemModel {
  final ProductModel product;
  final int attributeId;
  final int customizationId;
  int quantity;

  CartItemModel({
    required this.product,
    this.attributeId = 0,
    this.customizationId = 0,
    this.quantity = 1,
  });

  String get key => '${product.id}_${attributeId}_$customizationId';
}

@freezed
class CartModel with _$CartModel {
  const factory CartModel({
    @DefensiveIntConverter() @JsonKey(name: 'id_cart') @Default(0) int idCart,
    @DefensiveDoubleConverter() @Default(0) double total,
    @DefensiveDoubleConverter() @JsonKey(name: 'total_products') @Default(0) double totalProducts,
    @DefensiveDoubleConverter() @JsonKey(name: 'total_shipping') @Default(0) double totalShipping,
    @DefensiveDoubleConverter() @JsonKey(name: 'discount_amount') @Default(0) double discountAmount,
  }) = _CartModel;

  factory CartModel.fromJson(Map<String, dynamic> json) => _$CartModelFromJson(json);
}
