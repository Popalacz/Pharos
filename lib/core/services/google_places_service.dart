import 'package:pharos/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:pharos/core/network/http_client.dart';

class GooglePlacesService {
  final Dio _dio = createHttpClient();
  final String _apiKey;

  GooglePlacesService(this._apiKey);

  Future<List<dynamic>> getSuggestions(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
          'language': 'pl',
          'components': 'country:pl',
          'types': 'address',
        },
      );
      
      if (response.data['status'] == 'OK') {
        return response.data['predictions'];
      }
      return [];
    } catch (e) {
      AppLog.e('Places API Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'language': 'pl',
          'fields': 'address_components',
        },
      );
      
      if (response.data['status'] == 'OK') {
        return response.data['result'];
      }
      return null;
    } catch (e) {
      AppLog.e('Place Details Error: $e');
      return null;
    }
  }
}
