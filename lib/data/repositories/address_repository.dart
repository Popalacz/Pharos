import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_service.dart';
import '../models/address_model.dart';
import 'package:flutter/foundation.dart';

abstract class IAddressRepository {
  Future<List<AddressModel>> getAddresses(int customerId);
  Future<Map<String, dynamic>> addAddress(int customerId, AddressModel address);
  Future<Map<String, dynamic>> updateAddress(AddressModel address);
  Future<bool> deleteAddress(int addressId);
}

class AddressRepository implements IAddressRepository {
  final ApiService _apiService = ApiService();
  final bool useMockData;

  AddressRepository({this.useMockData = false});

  @override
  Future<List<AddressModel>> getAddresses(int customerId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        AddressModel(id: 1, alias: 'Dom', firstname: 'Jan', lastname: 'Kowalski', address1: 'ul. Przykładowa 12/4', postcode: '00-001', city: 'Warszawa', country: 'Polska', phone: '123456789'),
        AddressModel(id: 2, alias: 'Praca', firstname: 'Jan', lastname: 'Kowalski', address1: 'Al. Jerozolimskie 100', postcode: '00-100', city: 'Warszawa', country: 'Polska'),
      ];
    }
    
    try {
      final response = await _apiService.dio.get('/api/addresses', queryParameters: {
        'display': 'full',
        'filter[id_customer]': '[$customerId]',
        'filter[deleted]': '0',
      });
      
      final dynamic rawData = response.data['addresses'];
      if (rawData == null || rawData == '') return [];
      
      List jsonList = (rawData is List) ? rawData : [rawData];
      return jsonList.map((e) => AddressModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Fetch Addresses Error: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> addAddress(int customerId, AddressModel address) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'add',
      }, data: {
        'id_customer': customerId,
        ...address.toJson(),
      });
      
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      
      if (data['success'] != true) {
        debugPrint('API ADDRESS ERROR: ${data['message']} - ${data['debug'] ?? ''}');
      }
      
      return data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        debugPrint('ADDRESS SERVER ERROR: ${e.response?.data}');
        return {'success': false, 'message': 'Błąd serwera: ${e.response?.statusCode}'};
      }
      return {'success': false, 'message': 'Błąd połączenia'};
    }
  }

  @override
  Future<Map<String, dynamic>> updateAddress(AddressModel address) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'update',
      }, data: address.toJson());
      
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Błąd połączenia'};
    }
  }

  @override
  Future<bool> deleteAddress(int addressId) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'delete',
      }, data: {'id_address': addressId});
      
      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
