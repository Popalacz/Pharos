import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gapi;
import 'package:pharos/core/config/google_config.dart';
import 'package:http/http.dart' as http;

class GoogleCalendarService {
  static const _scopes = [gapi.CalendarApi.calendarEventsScope];

  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  GoogleSignInAccount? _currentUser;
  bool _isInitialized = false;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    if (GoogleConfig.hasServerClientId) {
      await _googleSignIn.initialize(serverClientId: GoogleConfig.serverClientId);
    } else {
      await _googleSignIn.initialize();
    }

    _isInitialized = true;
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      _currentUser = await _googleSignIn.authenticate(scopeHint: _scopes);
      return _currentUser;
    } catch (error) {
      debugPrint('Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> createLogisticsEvent({
    required String orderId,
    required String customerName,
    required double totalAmount,
    required List<String> items,
  }) =>
      addOrderEvent(
        orderId: orderId,
        customerName: customerName,
        totalAmount: totalAmount,
        items: items,
      );

  Future<void> addOrderEvent({
    required String orderId,
    required String customerName,
    required double totalAmount,
    required List<String> items,
  }) async {
    try {
      await _ensureInitialized();
      if (_currentUser == null) {
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
