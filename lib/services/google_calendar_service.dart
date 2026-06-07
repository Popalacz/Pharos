import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

import 'package:http/http.dart' as http; // Zamiast usuniętej paczki, używamy standardowego protokołu HTTP

class GoogleCalendarService {
  // Definiujemy zakres uprawnień (tylko zapis/odczyt kalendarza)
  static const _scopes = [CalendarApi.calendarEventsScope];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  /// Metoda odpowiedzialna za zalogowanie administratora do konta Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Błąd logowania Google Sign-In: $error');
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
    // Sprawdzenie, czy jesteśmy zalogowani
    var account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();

    if (account == null) {
      print('Użytkownik nie jest zalogowany do Google. Pomijam dodawanie do kalendarza.');
      return;
    }

    // Pobranie uwierzytelnionego klienta HTTP dedykowanego dla API Google
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) return;

    final calendarApi = CalendarApi(httpClient);

    // Tworzenie opisu wydarzenia z listą produktów
    // Budowanie opisu tekstowego - POPRAWIONE z writeline na writeln
    final descriptionBuilder = StringBuffer()
      ..writeln('Nowe zamówienie ze sklepu Pharos!')
      ..writeln('Klient: $customerName')
      ..writeln('Wartość: ${totalAmount.toStringAsFixed(2)} PLN')
      ..writeln('\nZakupione produkty:')
      ..writeAll(items.map((item) => '- $item'), '\n');

    // Definicja czasu trwania zadania (np. 1 godzina na spakowanie paczki)
    final startTime = DateTime.now().add(const Duration(minutes: 10)); // start za 10 minut
    final endTime = startTime.add(const Duration(hours: 1));

    final event = Event(
      summary: '📦 Realizacja zamówienia #$orderId',
      description: descriptionBuilder.toString(),
      start: EventDateTime(
        dateTime: startTime.toUtc(),
        timeZone: 'UTC',
      ),
      end: EventDateTime(
        dateTime: endTime.toUtc(),
        timeZone: 'UTC',
      ),
      colorId: '6', // Kolor jasnoczerwony/pomarańczowy w kalendarzu Google dla priorytetów
    );

    try {
      // Wstawienie zdarzenia do głównego kalendarza użytkownika
      await calendarApi.events.insert(event, 'primary');
      print('Zdarzenie dla zamówienia #$orderId pomyślnie dodane do kalendarza!');
    } catch (e) {
      print('Błąd podczas dodawania wydarzenia do Kalendarza Google: $e');
    }
  }
}