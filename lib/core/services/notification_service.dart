import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Użytkownik zezwolił na powiadomienia');
        
        String? token = await _fcm.getToken();
        debugPrint('FCM TOKEN: $token');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Otrzymano powiadomienie w aplikacji: ${message.notification?.title}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Kliknięto w powiadomienie: ${message.data['order_id']}');
      });
    } catch (e) {
      debugPrint('Notification Init Error: $e');
    }
  }
}
