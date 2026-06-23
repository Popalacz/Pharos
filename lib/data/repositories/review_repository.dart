import 'package:fpdart/fpdart.dart';
import '../../core/network/api_service.dart';
import '../../core/error/failures.dart';
import '../models/review_model.dart';

abstract class IReviewRepository {
  Future<Either<Failure, List<ReviewModel>>> getProductReviews(int productId);
  Future<Either<Failure, bool>> addProductReview({
    required int productId, 
    required int customerId, 
    required double rating, 
    required String comment,
    String? title,
  });
  Future<Either<Failure, bool>> addOrderReview({
    required int orderId, 
    required int customerId, 
    required double rating, 
    required String comment,
  });
}

class ReviewRepository implements IReviewRepository {
  final ApiService _apiService;
  final bool useMockData;

  ReviewRepository({ApiService? apiService, this.useMockData = false}) 
    : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<ReviewModel>>> getProductReviews(int productId) async {
    if (useMockData) {
      return Right([
        ReviewModel(id: 1, customerName: 'Marek V.', rating: 5, comment: 'Świetna jakość, polecam!', date: '2024-03-01'),
        ReviewModel(id: 2, customerName: 'Ania K.', rating: 4, comment: 'Produkt zgodny z opisem, szybka dostawa.', date: '2024-02-15'),
      ]);
    }
    
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'reviews',
        'action': 'get_product_reviews',
        'id_product': productId,
      },
      mapper: (json) {
        final List rawData = json['reviews'] ?? [];
        return rawData.map((e) => ReviewModel.fromJson(e)).toList();
      },
    );
  }

  @override
  Future<Either<Failure, bool>> addProductReview({
    required int productId, 
    required int customerId, 
    required double rating, 
    required String comment,
    String? title,
  }) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'reviews',
        'action': 'add_product_review',
      },
      data: {
        'id_product': productId,
        'id_customer': customerId,
        'grade': rating,
        'content': comment,
        'title': title ?? 'Opinia z aplikacji',
      },
      mapper: (json) => json['success'] == true,
    );
  }

  @override
  Future<Either<Failure, bool>> addOrderReview({
    required int orderId, 
    required int customerId, 
    required double rating, 
    required String comment,
  }) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'reviews',
        'action': 'add_order_review',
      },
      data: {
        'id_order': orderId,
        'id_customer': customerId,
        'grade': rating,
        'content': comment,
      },
      mapper: (json) => json['success'] == true,
    );
  }
}
