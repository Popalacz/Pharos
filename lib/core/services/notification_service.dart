import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Prośba o uprawnienia (ważne w iOS i Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Użytkownik zezwolił na powiadomienia');
      
      // Pobierz Token FCM - Musisz go wysłać do PrestaShop i zapisać przy koncie klienta
      String? token = await _fcm.getToken();
      debugPrint('FCM TOKEN: $token');
      // TODO: ApiService().sendTokenToPrestaShop(token);
    }

    // Obsługa powiadomień gdy aplikacja jest włączona (foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Otrzymano powiadomienie w aplikacji: ${message.notification?.title}');
    });

    // Obsługa kliknięcia w powiadomienie
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Kliknięto w powiadomienie: ${message.data['order_id']}');
      // Tu możemy nawigować do konkretnego zamówienia
    });
  }
}
