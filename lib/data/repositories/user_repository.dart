import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

abstract class IUserRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register({
    required String email, 
    required String password, 
    required String firstname, 
    required String lastname
  });
  Future<UserModel?> loginWithGoogle(String token, String email, String name);
  Future<bool> updateProfile(int customerId, Map<String, dynamic> data);
  Future<bool> changePassword(int customerId, String oldPassword, String newPassword);
}

class UserRepository implements IUserRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<bool> updateProfile(int customerId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
        'action': 'update_profile',
      }, data: {
        'id_customer': customerId,
        ...data,
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> changePassword(int customerId, String oldPassword, String newPassword) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
        'action': 'change_password',
      }, data: {
        'id_customer': customerId,
        'old_password': oldPassword,
        'new_password': newPassword,
      });
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Proszę podać e-mail i hasło.'};
    }

    try {
      // Używamy x-www-form-urlencoded dla maksymalnej kompatybilności z PHP
      final response = await _apiService.dio.post('/index.php', 
        queryParameters: {
          'fc': 'module',
          'module': 'pharosapi',
          'controller': 'auth', // Próbujemy auth, jeśli nie zadziała spróbuj authentication
        }, 
        data: {
          'action': 'login',
          'email': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return response.data is Map ? response.data : {'success': false, 'message': 'Nieprawidłowy format odpowiedzi.'};
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email, 
    required String password, 
    required String firstname, 
    required String lastname
  }) async {
    try {
      final response = await _apiService.dio.post('/index.php', 
        queryParameters: {
          'fc': 'module',
          'module': 'pharosapi',
          'controller': 'auth',
        }, 
        data: {
          'action': 'register',
          'email': email,
          'password': password,
          'firstname': firstname,
          'lastname': lastname,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return response.data is Map ? response.data : {'success': false, 'message': 'Nieprawidłowy format odpowiedzi.'};
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Map<String, dynamic> _handleAuthError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 404) {
        return {'success': false, 'message': 'Kontroler [auth] nie został znaleziony (404). Sprawdź czy plik controllers/front/auth.php istnieje w module.'};
      }
      if (e.response?.statusCode == 500) {
        return {'success': false, 'message': 'Błąd serwera (500). Sprawdź logi PHP w PrestaShop.'};
      }
    }
    return {'success': false, 'message': 'Błąd połączenia: ${e.toString()}'};
  }

  @override
  Future<UserModel?> loginWithGoogle(String token, String email, String name) async {
    try {
      final response = await _apiService.dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
        'action': 'google_login',
      }, data: {
        'token': token,
        'email': email,
        'name': name,
      });

      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['customer']);
      }
      return null;
    } catch (e) {
      debugPrint('Google Login API Error: $e');
      return null;
    }
  }
}
