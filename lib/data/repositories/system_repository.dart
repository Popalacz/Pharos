import 'package:fpdart/fpdart.dart';
import '../../core/network/api_service.dart';
import '../../core/error/failures.dart';

abstract class ISystemRepository {
  Future<Either<Failure, String?>> getConfiguration(String name);
  Future<Either<Failure, Map<String, String>>> getMultipleConfigurations(List<String> names);
}

class SystemRepository implements ISystemRepository {
  final ApiService _apiService;

  SystemRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, String?>> getConfiguration(String name) async {
    return _apiService.getSafe(
      '/api/configurations',
      queryParameters: {
        'filter[name]': '[$name]',
        'display': '[value]',
      },
      mapper: (json) {
        final dynamic configs = json['configurations'];
        if (configs is List && configs.isNotEmpty) {
          return configs.first['value']?.toString();
        } else if (configs is Map) {
          return configs['value']?.toString();
        }
        return null;
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, String>>> getMultipleConfigurations(List<String> names) async {
    final String filterValue = names.join('|');
    return _apiService.getSafe(
      '/api/configurations',
      queryParameters: {
        'filter[name]': '[$filterValue]',
        'display': '[name,value]',
      },
      mapper: (json) {
        final dynamic configs = json['configurations'];
        final Map<String, String> results = {};
        
        if (configs is List) {
          for (var item in configs) {
            results[item['name'].toString()] = item['value'].toString();
          }
        } else if (configs is Map) {
          results[configs['name'].toString()] = configs['value'].toString();
        }
        
        return results;
      },
    );
  }
}
