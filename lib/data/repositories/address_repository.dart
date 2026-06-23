import 'package:fpdart/fpdart.dart';
import '../../core/network/api_service.dart';
import '../../core/error/failures.dart';
import '../models/address_model.dart';

abstract class IAddressRepository {
  Future<Either<Failure, List<AddressModel>>> getAddresses(int customerId);
  Future<Either<Failure, Map<String, dynamic>>> addAddress(int customerId, AddressModel address);
  Future<Either<Failure, Map<String, dynamic>>> updateAddress(AddressModel address);
  Future<Either<Failure, bool>> deleteAddress(int addressId);
}

class AddressRepository implements IAddressRepository {
  final ApiService _apiService;

  AddressRepository({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  @override
  Future<Either<Failure, List<AddressModel>>> getAddresses(int customerId) async {
    return _apiService.getSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'list',
        'id_customer': customerId,
      },
      mapper: (json) {
        if (json['success'] == true) {
          final List rawData = json['addresses'] ?? [];
          return rawData.map((e) => AddressModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addAddress(int customerId, AddressModel address) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'add',
      },
      data: {
        'id_customer': customerId,
        ...address.toJson(),
      },
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateAddress(AddressModel address) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'update',
      },
      data: address.toJson(),
      mapper: (json) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<Either<Failure, bool>> deleteAddress(int addressId) async {
    return _apiService.postSafe(
      '/index.php',
      queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'address',
        'action': 'delete',
      },
      data: {'id_address': addressId},
      mapper: (json) => (json is Map && json['success'] == true),
    );
  }
}
