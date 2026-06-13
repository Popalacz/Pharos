import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharos/services/google_calendar_service.dart';

class UserProvider extends ChangeNotifier {
  final GoogleCalendarService _googleService = GoogleCalendarService();
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;
  bool get isLoggedIn => _user != null;

  UserProvider() {
    // Sprawdź czy użytkownik jest już zalogowany (silent sign in)
    _init();
  }

  Future<void> _init() async {
    _user = _googleService.currentUser;
    notifyListeners();
  }

  Future<void> signIn() async {
    _user = await _googleService.signIn();
    notifyListeners();
  }

  Future<void> signOut() async {
    // Dodaj metodę signOut do GoogleCalendarService jeśli jej brakuje
    // Na potrzeby MVP przyjmujemy prosty logout
    _user = null;
    notifyListeners();
  }
}
