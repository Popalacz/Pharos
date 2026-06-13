import 'package:flutter/material.dart';
import 'package:pharos/data/models/product_model.dart';
import 'package:pharos/data/repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  final IWishlistRepository _repository = WishlistRepository(useMockData: true);
  final Set<int> _wishlistIds = {};
  List<ProductModel> _wishlistProducts = [];
  bool _isLoading = false;

  Set<int> get wishlistIds => _wishlistIds;
  List<ProductModel> get wishlistProducts => _wishlistProducts;
  bool get isLoading => _isLoading;

  WishlistProvider() {
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();
    try {
      _wishlistProducts = await _repository.getWishlist();
      _wishlistIds.clear();
      for (var p in _wishlistProducts) {
        _wishlistIds.add(p.id);
      }
    } catch (e) {
      debugPrint('Wishlist Fetch Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(int productId) => _wishlistIds.contains(productId);

  Future<void> toggleWishlist(ProductModel product) async {
    if (isFavorite(product.id)) {
      _wishlistIds.remove(product.id);
      _wishlistProducts.removeWhere((p) => p.id == product.id);
    } else {
      _wishlistIds.add(product.id);
      _wishlistProducts.add(product);
    }
    notifyListeners();

    try {
      await _repository.toggleWishlist(product.id);
    } catch (e) {
      // Rollback on error
      if (isFavorite(product.id)) {
        _wishlistIds.remove(product.id);
        _wishlistProducts.removeWhere((p) => p.id == product.id);
      } else {
        _wishlistIds.add(product.id);
        _wishlistProducts.add(product);
      }
      notifyListeners();
    }
  }
}
