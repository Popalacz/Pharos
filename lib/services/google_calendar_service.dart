// ignore: unused_import
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';

// ROZWIĄZANIE DLA LINUKSA: Jawne pokazanie klas zapobiega ukrywaniu konstruktorów 
// przez specyficzne dla platformy desktopowej pliki nagłówkowe w pub-cache paczki.
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn, GoogleSignInAccount;

// Pełna izolacja klas kalendarza za pomocą aliasu 'gapi'
import 'package:googleapis/calendar/v3.dart' as gapi;

class GoogleCalendarService {
  static const _scopes = [gapi.CalendarApi.calendarEventsScope];

  // Konstruktor bez słowa kluczowego const
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  /// Metoda odpowiedzialna za zalogowanie administratora do konta Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      debugPrint('Błąd logowania Google Sign-In: $error');
      return null;
    }
  }

  /// Automatyczne dodawanie zdarzenia e-commerce do Kalendarza Google
  Future<void> addOrderEvent({
    required String orderId,
    required String customerName,
    required double totalAmount,
    required List<String> items,
  }) async {
    var account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();

    if (account == null) {
      debugPrint('Użytkownik nie jest zalogowany do Google. Pomijam dodawanie do kalendarza.');
      return;
    }

    // Pobranie uwierzytelnionego klienta HTTP z paczki rozszerzeń
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      debugPrint('Nie udało się uzyskać uwierzytelnionego klienta HTTP.');
      return;
    }

    final calendarApi = gapi.CalendarApi(httpClient);

    final descriptionBuilder = StringBuffer()
      ..writeln('Nowe zamówienie ze sklepu Pharos!')
      ..writeln('Klient: $customerName')
      ..writeln('Wartość: ${totalAmount.toStringAsFixed(2)} PLN')
      ..writeln('\nZakupione produkty:');
    
    for (final item in items) {
      descriptionBuilder.writeln('- $item');
    }

    final startTime = DateTime.now().add(const Duration(minutes: 10));
    final endTime = startTime.add(const Duration(hours: 1));

    final event = gapi.Event(
      summary: '📦 Realizacja zamówienia #$orderId',
      description: descriptionBuilder.toString(),
      start: gapi.EventDateTime(
        dateTime: startTime.toUtc(),
        timeZone: 'UTC',
      ),
      end: gapi.EventDateTime(
        dateTime: endTime.toUtc(),
        timeZone: 'UTC',
      ),
      colorId: '6',
    );

    try {
      await calendarApi.events.insert(event, 'primary');
      debugPrint('Zdarzenie dla zamówienia #$orderId pomyślnie dodane do kalendarza!');
    } catch (e) {
      debugPrint('Błąd podczas dodawania wydarzenia do Kalendarza Google: $e');
    }
  }
}