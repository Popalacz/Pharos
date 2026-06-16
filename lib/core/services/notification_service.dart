import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharos/main.dart';
import 'package:pharos/ui/screens/order_tracking_screen.dart';
import 'package:pharos/data/models/order_model.dart';

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
        if (token != null) {
          debugPrint('FCM TOKEN: $token');
          _syncTokenWithServer(token);
        }
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Otrzymano powiadomienie w aplikacji: ${message.notification?.title}');
        // Można pokazać lokalny toast/snackbar
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
      
      // Sprawdź czy aplikacja została uruchomiona z powiadomienia (gdy była zamknięta)
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('Notification Init Error: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'order_update' && message.data['order_id'] != null) {
      final orderId = int.tryParse(message.data['order_id'].toString()) ?? 0;
      final orderRef = message.data['order_reference'] ?? '---';

      // Nawigacja do szczegółów zamówienia
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
            order: OrderModel(
              id: orderId,
              reference: orderRef,
              date: DateTime.now().toString(),
              totalPaid: 0.0,
              status: 'Aktualizacja...',
              paymentMethod: '',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _syncTokenWithServer(String token) async {
    try {
      final dio = Dio(); // Proste wywołanie bez Basic Auth dla tokenów FCM
      await dio.post('https://pharos-api.tech/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'fcmtoken',
      }, data: {
        'token': token,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));
      debugPrint('FCM: Token synchronized with PrestaShop');
    } catch (e) {
      debugPrint('FCM: Failed to sync token: $e');
    }
  }
}
