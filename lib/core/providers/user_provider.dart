import 'package:pharos/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharos/services/google_calendar_service.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/data/repositories/address_repository.dart';

import 'package:pharos/data/models/user_model.dart';
import 'package:pharos/data/repositories/user_repository.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/core/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local_auth/local_auth.dart';
import '../error/failures.dart';

class UserProvider extends ChangeNotifier {
  final GoogleCalendarService _googleService = GoogleCalendarService();
  final IAddressRepository _addressRepository;
  final IUserRepository _userRepository;
  final LocalAuthentication _localAuth = LocalAuthentication();
  
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

  UserProvider({ApiService? apiService, IUserRepository? repository}) 
    : _userRepository = repository ?? UserRepository(apiService: apiService),
      _addressRepository = AddressRepository(apiService: apiService);

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    
    final result = await _userRepository.login(email, password);
    
    return result.fold(
      (failure) {
        _authError = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (data) async {
        if (data['success'] == true) {
          _user = UserModel.fromJson(data['customer']);
          await _syncFcmToken();
          await fetchAddresses();
          _isLoading = false;
          notifyListeners();
          return true;
        }
        _authError = data['message'] ?? 'Błąd logowania.';
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
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
    
    return result.fold(
      (failure) {
        _authError = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (data) async {
        if (data['success'] == true) {
          _user = UserModel.fromJson(data['customer']);
          await _syncFcmToken();
          await fetchAddresses();
          _isLoading = false;
          notifyListeners();
          return true;
        }
        _authError = data['message'] ?? 'Błąd rejestracji.';
        _isLoading = false;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _authError = null;
    notifyListeners();
    
    try {
      final googleUser = await _googleService.signIn();
      if (googleUser != null) {
        final result = await _userRepository.loginWithGoogle(
          googleUser.authentication.idToken ?? '',
          googleUser.email,
          googleUser.displayName ?? '',
        );
        
        await result.fold(
          (failure) async {
            // Jeśli API PrestaShop nie odpowiada, logujemy lokalnie jako fallback
            // ale informujemy o błędzie synchronizacji jeśli to istotne
            AppLog.e('PrestaShop Google Login Error: ${failure.message}');
            _user = UserModel(
              id: 0, 
              email: googleUser.email, 
              firstname: googleUser.displayName?.split(' ').first ?? 'User', 
              lastname: googleUser.displayName?.split(' ').last ?? '',
              photoUrl: googleUser.photoUrl,
            );
          },
          (userModel) async {
            _user = userModel;
          },
        );
        await _syncFcmToken();
        await fetchAddresses();
      } else {
        _authError = 'Logowanie Google zostało przerwane lub wystąpił błąd konfiguracji.';
      }
    } catch (e) {
      AppLog.e('Google Sign-In Exception: $e');
      _authError = 'Wystąpił nieoczekiwany błąd podczas logowania przez Google.';
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
    
    final result = await _addressRepository.getAddresses(_user!.id);
    
    result.fold(
      (failure) => AppLog.e('Error fetching addresses: $failure'),
      (addresses) {
        _addresses = addresses;
      },
    );

    _isLoadingAddresses = false;
    notifyListeners();
  }

  Future<bool> addAddress(AddressModel address) async {
    if (_user == null) return false;
    _addressError = null;
    final result = await _addressRepository.addAddress(_user!.id, address);
    
    return result.fold(
      (failure) {
        _addressError = failure.message;
        return false;
      },
      (data) async {
        if (data['success'] == true) {
          await fetchAddresses();
          return true;
        }
        _addressError = data['message'] ?? 'Nie udało się zapisać adresu.';
        return false;
      },
    );
  }

  Future<bool> updateAddress(AddressModel address) async {
    _addressError = null;
    final result = await _addressRepository.updateAddress(address);
    
    return result.fold(
      (failure) {
        _addressError = failure.message;
        return false;
      },
      (data) async {
        if (data['success'] == true) {
          await fetchAddresses();
          return true;
        }
        _addressError = data['message'] ?? 'Nie udało się zaktualizować adresu.';
        return false;
      },
    );
  }

  Future<bool> deleteAddress(int addressId) async {
    final result = await _addressRepository.deleteAddress(addressId);
    
    return result.fold(
      (failure) => false,
      (success) async {
        if (success) await fetchAddresses();
        return success;
      },
    );
  }

  Future<bool> updateProfile({String? firstname, String? lastname, String? email}) async {
    if (_user == null) return false;
    
    final Map<String, dynamic> data = {};
    if (firstname != null) data['firstname'] = firstname;
    if (lastname != null) data['lastname'] = lastname;
    if (email != null) data['email'] = email;

    final result = await _userRepository.updateProfile(_user!.id, data);
    
    return result.fold(
      (failure) => false,
      (success) {
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
      },
    );
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    if (_user == null) return false;
    final result = await _userRepository.changePassword(_user!.id, oldPass, newPass);
    return result.fold((failure) => false, (success) => success);
  }

  Future<void> logisticsAutomation({required String orderId, required double amount}) async {
    try {
      // Pobieramy dane o zamówieniu (w prawdziwej apce z PrestaShop)
      // Tutaj używamy naszego serwisu Google Calendar (Twój Cel nr 5)
      await _googleService.createLogisticsEvent(
        orderId: orderId,
        customerName: _user?.displayName ?? 'Klient Pharos',
        totalAmount: amount,
        items: ['Zamówienie z aplikacji mobilnej'],
      );
    } catch (e) {
      AppLog.e('Logistics Automation Error: $e');
    }
  }

  Future<bool> authenticateBiometrically() async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return true;

      return await _localAuth.authenticate(
        localizedReason: 'Potwierdź tożsamość odciskiem, Face ID lub PIN urządzenia',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      AppLog.e('Biometric Error: $e');
      return false;
    }
  }

  Future<void> _syncFcmToken() async {
    if (_user == null) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await NotificationService().syncTokenWithServer(
          token: token,
          customerId: _user!.id,
          languageId: ApiService.defaultLanguageId,
        );
      }
    } catch (e) {
      AppLog.e('Error syncing FCM token: $e');
    }
  }
}
