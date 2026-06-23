import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/user_model.dart';
import '../../core/error/failures.dart';
import 'package:pharos/core/api/api_config.dart';

abstract class IUserRepository {
  Future<Either<Failure, Map<String, dynamic>>> login(String email, String password);
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email, 
    required String password, 
    required String firstname, 
    required String lastname
  });
  Future<Either<Failure, UserModel>> loginWithGoogle(String token, String email, String name);
  Future<Either<Failure, bool>> updateProfile(int customerId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> changePassword(int customerId, String oldPassword, String newPassword);
}

class UserRepository implements IUserRepository {
  final ApiService _apiService;
  final bool useMockData;

  UserRepository({ApiService? apiService, bool? useMockData}) 
    : _apiService = apiService ?? ApiService(),
      useMockData = useMockData ?? ApiConfig.forceMockData;

  @override
  Future<Either<Failure, bool>> updateProfile(int customerId, Map<String, dynamic> data) async {
    if (useMockData) return const Right(true);
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
        'action': 'update_profile',
      },
      data: {
        'id_customer': customerId,
        ...data,
      },
      mapper: (json) => json['success'] == true,
    );
  }

  @override
  Future<Either<Failure, bool>> changePassword(int customerId, String oldPassword, String newPassword) async {
    if (useMockData) return const Right(true);
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
        'action': 'change_password',
      },
      data: {
        'id_customer': customerId,
        'old_password': oldPassword,
        'new_password': newPassword,
      },
      mapper: (json) => json['success'] == true,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(String email, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return Right({
        'success': true,
        'customer': {
          'id': 1,
          'email': email,
          'firstname': 'Google',
          'lastname': 'User (Mock)',
        }
      });
    }

    if (email.isEmpty || password.isEmpty) {
      return const Left(ServerFailure('Proszę podać e-mail i hasło.'));
    }

    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
      },
      data: {
        'action': 'login',
        'email': email,
        'password': password,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email, 
    required String password, 
    required String firstname, 
    required String lastname
  }) async {
    if (useMockData) {
      return Right({
        'success': true,
        'customer': {
          'id': 1,
          'email': email,
          'firstname': firstname,
          'lastname': lastname,
        }
      });
    }
    return _apiService.postSafe(
      '/index.php',
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
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, UserModel>> loginWithGoogle(String token, String email, String name) async {
    if (useMockData) {
       return Right(UserModel(id: 1, email: email, firstname: name, lastname: '(Google Mock)'));
    }
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'auth',
        'action': 'google_login',
      },
      data: {
        'token': token,
        'email': email,
        'name': name,
      },
      mapper: (json) {
        if (json['success'] == true) {
          return UserModel.fromJson(json['customer']);
        }
        throw Exception('Błąd logowania Google');
      },
    );
  }
}
