import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gapi;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';

class GoogleCalendarService {
  // Scopes wymagane do zapisu w kalendarzu
  static const _scopes = [gapi.CalendarApi.calendarEventsScope];

  // Singleton pattern dla serwisu
  static final GoogleCalendarService _instance = GoogleCalendarService._internal();
  factory GoogleCalendarService() => _instance;
  GoogleCalendarService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  /// Zwraca aktualnie zalogowanego użytkownika lub null
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Próba cichego logowania (jeśli już raz się zalogował)
      var account = await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();
      return account;
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
      final account = _googleSignIn.currentUser;
      if (account == null) throw Exception('Użytkownik niezalogowany');

      // Używamy oficjalnego rozszerzenia do pobrania uwierzytelnionego klienta
      final httpClient = await account.authenticatedClient();
      if (httpClient == null) throw Exception('Błąd uwierzytelnienia klienta');

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
        colorId: '6', // Pomarańczowy kolor Pharos
      );

      await calendarApi.events.insert(event, 'primary');
    } catch (e) {
      debugPrint('Calendar API Error: $e');
      rethrow;
    }
  }
}
