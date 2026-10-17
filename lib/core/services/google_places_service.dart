import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GooglePlacesService {
  final Dio _dio = Dio();
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
      debugPrint('Places API Error: $e');
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
      debugPrint('Place Details Error: $e');
      return null;
    }
  }
}
