import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharos/services/google_calendar_service.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/data/repositories/address_repository.dart';

import 'package:pharos/data/models/user_model.dart';
import 'package:pharos/data/repositories/user_repository.dart';
import 'package:pharos/core/network/api_service.dart';

class UserProvider extends ChangeNotifier {
  final GoogleCalendarService _googleService = GoogleCalendarService();
  final IAddressRepository _addressRepository = AddressRepository(useMockData: false);
  final IUserRepository _userRepository = UserRepository();
  
  UserModel? _user;
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  bool _isLoadingAddresses = false;
  String? _authError;
  String? _addressError;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  bool get isLoadingAddresses => _isLoadingAddresses;
  String? get authError => _authError;
  String? get addressError => _addressError;

  UserProvider() {
    // Tutaj można dodać ładowanie usera z secure storage
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    
    final result = await _userRepository.login(email, password);
    if (result['success'] == true) {
      _user = UserModel.fromJson(result['customer']);
      await fetchAddresses();
      _isLoading = false;
      notifyListeners();
      return true;
    }
    
    _authError = result['message'] ?? 'Błąd logowania.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email, 
    required String password, 
    required String firstname, 
    required String lastname
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    
    final result = await _userRepository.register(
      email: email, 
      password: password, 
      firstname: firstname, 
      lastname: lastname
    );
    
    if (result['success'] == true) {
      _user = UserModel.fromJson(result['customer']);
      await fetchAddresses();
      _isLoading = false;
      notifyListeners();
      return true;
    }
    
    _authError = result['message'] ?? 'Błąd rejestracji.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    
    final googleUser = await _googleService.signIn();
    if (googleUser != null) {
      // Synchronizacja z PrestaShop po zalogowaniu przez Google
      final result = await _userRepository.loginWithGoogle(
        'mock_token', // Docelowo token z googleUser.authentication
        googleUser.email,
        googleUser.displayName ?? '',
      );
      
      if (result != null) {
        _user = result;
      } else {
        // Fallback jeśli API Presty zawiedzie, ale Google przeszło
        _user = UserModel(
          id: 0, 
          email: googleUser.email, 
          firstname: googleUser.displayName?.split(' ').first ?? 'User', 
          lastname: googleUser.displayName?.split(' ').last ?? '',
          photoUrl: googleUser.photoUrl,
        );
      }
      await fetchAddresses();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    _addresses = [];
    // Czyścimy sesję w API przy wylogowaniu
    ApiService.clearSession();
    notifyListeners();
  }

  Future<void> fetchAddresses() async {
    if (_user == null) return;
    _isLoadingAddresses = true;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getAddresses(_user!.id);
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(AddressModel address) async {
    if (_user == null) return false;
    _addressError = null;
    final result = await _addressRepository.addAddress(_user!.id, address);
    if (result['success'] == true) {
      await fetchAddresses();
      return true;
    }
    _addressError = result['message'] ?? 'Nie udało się zapisać adresu.';
    return false;
  }

  Future<bool> updateAddress(AddressModel address) async {
    _addressError = null;
    final result = await _addressRepository.updateAddress(address);
    if (result['success'] == true) {
      await fetchAddresses();
      return true;
    }
    _addressError = result['message'] ?? 'Nie udało się zaktualizować adresu.';
    return false;
  }

  Future<bool> deleteAddress(int addressId) async {
    final success = await _addressRepository.deleteAddress(addressId);
    if (success) await fetchAddresses();
    return success;
  }

  Future<bool> updateProfile({String? firstname, String? lastname, String? email}) async {
    if (_user == null) return false;
    
    final Map<String, dynamic> data = {};
    if (firstname != null) data['firstname'] = firstname;
    if (lastname != null) data['lastname'] = lastname;
    if (email != null) data['email'] = email;

    final success = await _userRepository.updateProfile(_user!.id, data);
    if (success) {
      _user = UserModel(
        id: _user!.id,
        email: email ?? _user!.email,
        firstname: firstname ?? _user!.firstname,
        lastname: lastname ?? _user!.lastname,
        photoUrl: _user!.photoUrl,
        birthday: _user!.birthday,
        newsletter: _user!.newsletter,
      );
      notifyListeners();
    }
    return success;
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    if (_user == null) return false;
    return await _userRepository.changePassword(_user!.id, oldPass, newPass);
  }

  Future<void> logisticsAutomation({required String orderId, required double amount}) async {
    try {
      // Pobieramy dane o zamówieniu (w prawdziwej apce z PrestaShop)
      // Tutaj używamy naszego serwisu Google Calendar (Twój Cel nr 5)
      await _googleService.addOrderEvent(
        orderId: orderId,
        customerName: _user?.displayName ?? 'Klient Pharos',
        totalAmount: amount,
        items: ['Zamówienie z aplikacji mobilnej'], // Docelowo lista z koszyka
      );
    } catch (e) {
      debugPrint('Logistics Automation Error: $e');
    }
  }
}
