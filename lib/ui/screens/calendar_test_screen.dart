import 'package:flutter/material.dart';
import 'package:pharos/services/google_calendar_service.dart';

class CalendarTestScreen extends StatefulWidget {
  const CalendarTestScreen({super.key});

  @override
  State<CalendarTestScreen> createState() => _CalendarTestScreenState();
}

class _CalendarTestScreenState extends State<CalendarTestScreen> {
  final GoogleCalendarService _calendarService = GoogleCalendarService();
  
  // Stany komponentów UI
  bool _isLoggingIn = false;
  bool _isSending = false;
  String _statusMessage = 'Status: Brak autoryzacji Google';
  String? _userEmail;

  // Metoda obsługująca kliknięcie przycisku logowania
  Future<void> _handleSignIn() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      final user = await _calendarService.signIn();

      setState(() {
        _isLoggingIn = false;
        if (user != null) {
          _userEmail = user.email;
          _statusMessage = 'Zalogowano pomyślnie';
        } else {
          _statusMessage = 'Logowanie anulowane przez użytkownika.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoggingIn = false;
        _statusMessage = 'Wystąpił błąd autoryzacji.';
      });
      
      // Wyświetlenie błędu bezpośrednio w UI za pomocą SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Błąd systemu Google: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // Metoda obsługująca dodanie testowego zamówienia
  Future<void> _handleSendTestOrder() async {
    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Najpierw musisz zalogować się do konta Google!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Wywołanie zewnętrznego API Google
      await _calendarService.addOrderEvent(
        orderId: 'PH-2026-881',
        customerName: 'Jan Kowalski (Student)',
        totalAmount: 549.99,
        items: [
          'Buty trekkingowe Salomon Speedcross - 1x',
          'Skarpetki termoaktywne Merino - 2x',
          'Plecak sportowy Pharos Edition - 1x'
        ],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sukces! Zamówienie zostało zaplanowane w Twoim kalendarzu.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nie udało się dodać wydarzenia: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Integracji Google'),
        backgroundColor: Colors.orange,
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nagłówek graficzny sekcji
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Icon(Icons.calendar_today_rounded, size: 70, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 32),
              
              // Blok statusu użytkownika
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (_userEmail != null) ...[
                const SizedBox(height: 8),
                Text(
                  _userEmail!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 48),
              
              // PRZYCISK 1: Logowanie OAuth2
              if (_isLoggingIn)
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange))
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _handleSignIn,
                    icon: const Icon(Icons.security, color: Colors.black87),
                    label: const Text('Zaloguj przez Google OAuth', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                
              const SizedBox(height: 16),
              
              // PRZYCISK 2: Wysłanie zdarzenia
              if (_isSending)
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange))
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _handleSendTestOrder,
                    icon: const Icon(Icons.add_to_photos_rounded),
                    label: const Text('Wyślij zamówienie do Kalendarza', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}