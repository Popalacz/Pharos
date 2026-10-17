import 'package:fpdart/fpdart.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_service.dart';
import '../models/filter_model.dart';

abstract class IFilterRepository {
  Future<Either<Failure, List<FilterGroup>>> getCatalogFilters();
}

class FilterRepository implements IFilterRepository {
  FilterRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  @override
  Future<Either<Failure, List<FilterGroup>>> getCatalogFilters() async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'products',
        'action': 'filters',
      },
      mapper: (json) {
        if (json is Map && json['status'] == 'success') {
          final List rawList = json['data'] ?? [];
          return rawList
              .map((item) => FilterGroup.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        throw Exception('Invalid filters API response');
      },
    );
  }
}
