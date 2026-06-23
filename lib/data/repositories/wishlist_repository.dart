import 'package:fpdart/fpdart.dart';
import '../models/product_model.dart';
import '../../core/network/api_service.dart';
import '../../core/error/failures.dart';

abstract class IWishlistRepository {
  Future<Either<Failure, List<ProductModel>>> getWishlist(int customerId);
  Future<Either<Failure, bool>> toggleWishlist(int customerId, int productId);
}

class WishlistRepository implements IWishlistRepository {
  final ApiService _apiService;
  final bool useMockData;

  WishlistRepository({ApiService? apiService, this.useMockData = false}) 
    : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<ProductModel>>> getWishlist(int customerId) async {
    if (useMockData) {
      return const Right([]); 
    }
    
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'wishlist',
        'action': 'get',
        'id_customer': customerId,
      },
      mapper: (json) {
        final dynamic rawData = json['products'];
        if (rawData == null || rawData == '') return [];
        List productsJson = (rawData is List) ? rawData : [rawData];
        return productsJson.map((j) => ProductModel.fromJson(j)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist(int customerId, int productId) async {
    if (useMockData) return const Right(true);
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'wishlist',
        'action': 'toggle',
      },
      data: {
        'id_customer': customerId,
        'id_product': productId,
      },
      mapper: (json) => json['success'] == true,
    );
  }
}
