import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/network/api_service.dart';
import '../../core/error/failures.dart';
import '../models/category_model.dart';

abstract class ICategoryRepository {
  Future<Either<Failure, List<CategoryModel>>> getCategories();
}

class CategoryRepository implements ICategoryRepository {
  final ApiService _apiService;

  CategoryRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'categories',
        'action': 'list',
      },
      mapper: (json) {
        final List categoriesJson = json['categories'] ?? [];
        return categoriesJson
            .map((j) => CategoryModel.fromJson(j as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
