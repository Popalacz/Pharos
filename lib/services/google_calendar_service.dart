import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gapi;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  // Scopes wymagane do zapisu w kalendarzu
  static const _scopes = [gapi.CalendarApi.calendarEventsScope];

  // Singleton pattern dla serwisu
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  // Używamy Twojej niestandardowej instancji .instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  GoogleSignInAccount? _currentUser;

  /// Zwraca aktualnie zalogowanego użytkownika lub null
  GoogleSignInAccount? get currentUser => _currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _googleSignIn.initialize();
      // Używamy Twojej metody authenticate() zamiast signIn()
      _currentUser = await _googleSignIn.authenticate(scopeHint: _scopes);
      return _currentUser;
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> addOrderEvent({
    required String orderId,
    required String customerName,
    required double totalAmount,
    required List<String> items,
  }) async {
    try {
      if (_currentUser == null) {
        await _googleSignIn.initialize();
        _currentUser = await _googleSignIn.attemptLightweightAuthentication();
        _currentUser ??= await _googleSignIn.authenticate(scopeHint: _scopes);
      }

      if (_currentUser == null) throw Exception('Użytkownik niezalogowany');

      // W Twojej wersji biblioteki używamy authorizationHeaders bezpośrednio
      final authHeaders = await _currentUser!.authorizationClient.authorizationHeaders(_scopes, promptIfNecessary: true);
      
      if (authHeaders == null) throw Exception('Błąd autoryzacji');

      final httpClient = AuthenticatedClient(authHeaders);
      final calendarApi = gapi.CalendarApi(httpClient);

      final description = StringBuffer()
        ..writeln('🛒 Nowe zamówienie Pharos: #$orderId')
        ..writeln('Odbiorca: $customerName')
        ..writeln('Wartość: ${totalAmount.toStringAsFixed(2)} PLN')
        ..writeln('\nProdukty:')
        ..writeAll(items.map((e) => '- $e'), '\n');

      final event = gapi.Event(
        summary: '📦 Realizacja #$orderId',
        description: description.toString(),
        start: gapi.EventDateTime(
          dateTime: DateTime.now().add(const Duration(hours: 2)).toUtc(),
          timeZone: 'UTC',
        ),
        end: gapi.EventDateTime(
          dateTime: DateTime.now().add(const Duration(hours: 3)).toUtc(),
          timeZone: 'UTC',
        ),
        colorId: '6',
      );

      await calendarApi.events.insert(event, 'primary');
    } catch (e) {
      debugPrint('Calendar API Error: $e');
      rethrow;
    }
  }
}

// Pomocniczy klient HTTP do obsługi nagłówków z Twojej wersji biblioteki
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final Map<String, String> _headers;

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
