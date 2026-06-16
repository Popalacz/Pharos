import 'package:flutter/foundation.dart';
import '../../core/network/api_service.dart';
import '../models/review_model.dart';

abstract class IReviewRepository {
  Future<List<ReviewModel>> getProductReviews(int productId);
  Future<bool> addProductReview({
    required int productId, 
    required int customerId, 
    required double rating, 
    required String comment,
    String? title,
  });
  Future<bool> addOrderReview({
    required int orderId, 
    required int customerId, 
    required double rating, 
    required String comment,
  });
}

class ReviewRepository implements IReviewRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  ReviewRepository({this.useMockData = false});

  @override
  Future<List<ReviewModel>> getProductReviews(int productId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [
        ReviewModel(id: 1, customerName: 'Marek V.', rating: 5, comment: 'Świetna jakość, polecam!', date: '2024-03-01'),
        ReviewModel(id: 2, customerName: 'Ania K.', rating: 4, comment: 'Produkt zgodny z opisem, szybka dostawa.', date: '2024-02-15'),
      ];
    }
    
    try {
      final response = await _apiService.dio.get('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'reviews',
        'action': 'get_product_reviews',
        'id_product': productId,
      });
      
      final List rawData = response.data['reviews'] ?? [];
      return rawData.map((e) => ReviewModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> addProductReview({
    required int productId, 
    required int customerId, 
    required double rating, 
    required String comment,
    String? title,
  }) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'reviews',
        'action': 'add_product_review',
      }, data: {
        'id_product': productId,
        'id_customer': customerId,
        'grade': rating,
        'content': comment,
        'title': title ?? 'Opinia z aplikacji',
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addOrderReview({
    required int orderId, 
    required int customerId, 
    required double rating, 
    required String comment,
  }) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'reviews',
        'action': 'add_order_review',
      }, data: {
        'id_order': orderId,
        'id_customer': customerId,
        'grade': rating,
        'content': comment,
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
