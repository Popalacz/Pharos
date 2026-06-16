import 'package:pharos/core/network/api_service.dart';
import '../models/category_model.dart';
import 'package:flutter/foundation.dart';

abstract class ICategoryRepository {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRepository implements ICategoryRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.dio.get('/api/categories', queryParameters: {
        'display': 'full',
        'filter[active]': '1',
      });
      
      final dynamic rawData = response.data['categories'];
      
      if (rawData == null || rawData == '') return [];
      
      List categoriesJson = [];
      if (rawData is List) {
        categoriesJson = rawData;
      } else if (rawData is Map) {
        categoriesJson = [rawData];
      }

      return categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .where((cat) => cat.id > 2)
          .toList();
    } catch (e) {
      debugPrint('Category Fetch Error: $e');
      return [];
    }
  }
}
