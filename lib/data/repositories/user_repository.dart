import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/data/models/user_model.dart';
import 'package:pharos/data/repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import 'package:pharos/core/api/api_config.dart';

abstract class IUserRepository {
  Future<Either<Failure, Map<String, dynamic>>> login(String email, String password);
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  });
  Future<Either<Failure, UserModel>> loginWithGoogle(String token, String email, String name);
  Future<Either<Failure, bool>> updateProfile(int customerId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> changePassword(int customerId, String oldPassword, String newPassword);
}

class UserRepository implements IUserRepository {
  final ApiService _apiService;
  final IAuthRepository _authRepository;
  final bool useMockData;

  UserRepository({
    ApiService? apiService,
    IAuthRepository? authRepository,
    bool? useMockData,
  })  : _apiService = apiService ?? ApiService(),
        _authRepository = authRepository ?? AuthRepository(apiService: apiService),
        useMockData = useMockData ?? ApiConfig.forceMockData;

  @override
  Future<Either<Failure, Map<String, dynamic>>> login(String email, String password) =>
      _authRepository.login(email, password);

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) =>
      _authRepository.register(
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      );

  @override
  Future<Either<Failure, UserModel>> loginWithGoogle(String token, String email, String name) =>
      _authRepository.loginWithGoogle(token, email, name);

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
  Future<Either<Failure, bool>> changePassword(
    int customerId,
    String oldPassword,
    String newPassword,
  ) async {
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
}
