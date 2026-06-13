import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharos/services/google_calendar_service.dart';
import 'package:pharos/data/models/address_model.dart';
import 'package:pharos/data/repositories/address_repository.dart';

class UserProvider extends ChangeNotifier {
  final GoogleCalendarService _googleService = GoogleCalendarService();
  final IAddressRepository _addressRepository = AddressRepository(useMockData: true);
  
  GoogleSignInAccount? _user;
  List<AddressModel> _addresses = [];
  bool _isLoadingAddresses = false;

  GoogleSignInAccount? get user => _user;
  bool get isLoggedIn => _user != null;
  List<AddressModel> get addresses => _addresses;
  bool get isLoadingAddresses => _isLoadingAddresses;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = _googleService.currentUser;
    if (isLoggedIn) {
      await fetchAddresses();
    }
    notifyListeners();
  }

  Future<void> signIn() async {
    _user = await _googleService.signIn();
    if (isLoggedIn) {
      await fetchAddresses();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    _addresses = [];
    notifyListeners();
  }

  Future<void> fetchAddresses() async {
    _isLoadingAddresses = true;
    notifyListeners();
    try {
      _addresses = await _addressRepository.getAddresses();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    } finally {
      _isLoadingAddresses = false;
      notifyListeners();
    }
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
