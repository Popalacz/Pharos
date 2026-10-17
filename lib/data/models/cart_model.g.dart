// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartModelImpl _$$CartModelImplFromJson(Map<String, dynamic> json) =>
    _$CartModelImpl(
      idCart: json['id_cart'] == null
          ? 0
          : const DefensiveIntConverter().fromJson(json['id_cart']),
      total: json['total'] == null
          ? 0
          : const DefensiveDoubleConverter().fromJson(json['total']),
      totalProducts: json['total_products'] == null
          ? 0
          : const DefensiveDoubleConverter().fromJson(json['total_products']),
      totalShipping: json['total_shipping'] == null
          ? 0
          : const DefensiveDoubleConverter().fromJson(json['total_shipping']),
      discountAmount: json['discount_amount'] == null
          ? 0
          : const DefensiveDoubleConverter().fromJson(json['discount_amount']),
    );

Map<String, dynamic> _$$CartModelImplToJson(_$CartModelImpl instance) =>
    <String, dynamic>{
      'id_cart': const DefensiveIntConverter().toJson(instance.idCart),
      'total': const DefensiveDoubleConverter().toJson(instance.total),
      'total_products': const DefensiveDoubleConverter().toJson(
        instance.totalProducts,
      ),
      'total_shipping': const DefensiveDoubleConverter().toJson(
        instance.totalShipping,
      ),
      'discount_amount': const DefensiveDoubleConverter().toJson(
        instance.discountAmount,
      ),
    };
