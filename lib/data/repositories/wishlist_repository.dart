import '../models/product_model.dart';
import '../../core/network/api_service.dart';

abstract class IWishlistRepository {
  Future<List<ProductModel>> getWishlist();
  Future<void> toggleWishlist(int productId);
}

class WishlistRepository implements IWishlistRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  WishlistRepository({this.useMockData = true});

  @override
  Future<List<ProductModel>> getWishlist() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Symulacja ulubionych produktów
      return []; 
    }
    
    final response = await _apiService.dio.get('/pharos/wishlist');
    return (response.data['products'] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> toggleWishlist(int productId) async {
    if (useMockData) return;
    await _apiService.dio.post('/pharos/wishlist/toggle', data: {'id_product': productId});
  }
}
