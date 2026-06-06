import 'product_model.dart';

/// One demo row in the cart sheet (name + price + optional image URL from Presta).
class CartStubLine {
  const CartStubLine({
    required this.productName,
    required this.unitPrice,
    required this.imageUrl,
  });

  final String productName;
  final String unitPrice;
  final String imageUrl;

  bool get hasThumbnail => imageUrl.isNotEmpty;

  factory CartStubLine.fromProduct(Product product) {
    return CartStubLine(
      productName: product.name,
      unitPrice: product.price,
      imageUrl: product.hasImageUrl ? product.imageUrl : '',
    );
  }
}
