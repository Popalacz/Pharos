import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gapi;
import 'package:http/http.dart' as http;

/// Klasa pomocnicza (Uwierzytelniony klient HTTP), która zastępuje problematyczną paczkę rozszerzeń
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

class GoogleCalendarService {
  static const _scopes = [gapi.CalendarApi.calendarEventsScope];

  // Instancja Singleton (.instance)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Metoda odpowiedzialna za zalogowanie administratora do konta Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _googleSignIn.initialize();
      final account = await _googleSignIn.authenticate();
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
    await _googleSignIn.initialize();

    var account = await _googleSignIn.attemptLightweightAuthentication();
    account ??= await _googleSignIn.authenticate();

    if (account == null) {
      debugPrint('Użytkownik nie jest zalogowany do Google. Pomijam dodawanie do kalendarza.');
      return;
    }

    try {
      // NOWOŚĆ: Pobieramy nagłówki autoryzacyjne wprost z nowego systemu Google SDK
      final Map<String, String>? authHeaders = await account.authorizationClient
          .authorizationHeaders(_scopes, promptIfNecessary: true);

      if (authHeaders == null) {
        debugPrint('Nie udało się uzyskać nagłówków autoryzacyjnych.');
        return;
      }

      // Tworzymy czysty, bezpieczny klient HTTP przy użyciu naszej klasy pomocniczej
      final httpClient = AuthenticatedClient(authHeaders);
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

      await calendarApi.events.insert(event, 'primary');
      debugPrint('Zdarzenie dla zamówienia #$orderId pomyślnie dodane do kalendarza!');
    } catch (e) {
      debugPrint('Błąd podczas dodawania wydarzenia do Kalendarza Google: $e');
    }
  }
}