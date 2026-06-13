import '../models/address_model.dart';

abstract class IAddressRepository {
  Future<List<AddressModel>> getAddresses();
  Future<void> addAddress(AddressModel address);
  Future<void> deleteAddress(int id);
}

class AddressRepository implements IAddressRepository {
  final bool useMockData;

  AddressRepository({this.useMockData = true});

  @override
  Future<List<AddressModel>> getAddresses() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return [
        AddressModel(
          id: 1,
          alias: 'Dom',
          firstname: 'Jan',
          lastname: 'Kowalski',
          address1: 'ul. Przykładowa 12/4',
          postcode: '00-001',
          city: 'Warszawa',
          country: 'Polska',
          phone: '123456789',
        ),
        AddressModel(
          id: 2,
          alias: 'Praca',
          firstname: 'Jan',
          lastname: 'Kowalski',
          address1: 'Al. Jerozolimskie 100',
          postcode: '00-100',
          city: 'Warszawa',
          country: 'Polska',
        ),
      ];
    }
    // Tu docelowo wywołanie dio do /addresses
    return [];
  }

  @override
  Future<void> addAddress(AddressModel address) async {
    // Implementacja POST /addresses
  }

  @override
  Future<void> deleteAddress(int id) async {
    // Implementacja DELETE /addresses/id
  }
}
