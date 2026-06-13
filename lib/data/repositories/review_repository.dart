import '../models/review_model.dart';

abstract class IReviewRepository {
  Future<List<ReviewModel>> getProductReviews(int productId);
  Future<void> addReview(int productId, double rating, String comment);
}

class ReviewRepository implements IReviewRepository {
  final bool useMockData;

  ReviewRepository({this.useMockData = true});

  @override
  Future<List<ReviewModel>> getProductReviews(int productId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return [
        ReviewModel(id: 1, customerName: 'Marek V.', rating: 5, comment: 'Świetna jakość, polecam!', date: '2024-03-01'),
        ReviewModel(id: 2, customerName: 'Ania K.', rating: 4, comment: 'Produkt zgodny z opisem, szybka dostawa.', date: '2024-02-15'),
      ];
    }
    return [];
  }

  @override
  Future<void> addReview(int productId, double rating, String comment) async {
    // Implementacja POST do modułu productcomments
  }
}
