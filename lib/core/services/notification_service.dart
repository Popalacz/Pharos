import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pharos/main.dart';
import 'package:pharos/ui/screens/order_tracking_screen.dart';
import 'package:pharos/data/models/order_model.dart';
import 'package:pharos/core/api/api_config.dart';
import 'package:pharos/core/network/api_service.dart';
import 'package:pharos/l10n/app_localizations.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _cachedToken;

  Future<void> initialize() async {
    try {
      final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final String? token = await _fcm.getToken();
        if (token != null) {
          _cachedToken = token;
          await syncTokenWithServer(
            token: token,
            languageId: ApiService.defaultLanguageId,
          );
        }
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground notification: ${message.notification?.title}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
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
      final context = navigatorKey.currentContext;
      final statusLabel = context != null
          ? AppLocalizations.of(context)!.orderStatusUpdating
          : message.data['status']?.toString() ?? 'Updating...';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(
            order: OrderModel(
              id: orderId,
              reference: orderRef,
              date: DateTime.now().toString(),
              totalPaid: 0.0,
              status: statusLabel,
              paymentMethod: '',
            ),
          ),
        ),
      );
    }
  }

  Future<void> syncTokenWithServer({
    required String token,
    int? customerId,
    int? languageId,
  }) async {
    try {
      _cachedToken = token;
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl.split('/api').first,
      ));

      await dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'fcmtoken',
      }, data: {
        'token': token,
        'id_customer': customerId,
        'id_lang': languageId,
      });
      debugPrint('FCM: Token synchronized for customer $customerId (lang: $languageId)');
    } catch (e) {
      debugPrint('FCM: Failed to sync token: $e');
    }
  }

  Future<void> resyncCurrentToken({int? customerId, int? languageId}) async {
    final token = _cachedToken ?? await _fcm.getToken();
    if (token == null) {
      return;
    }

    await syncTokenWithServer(
      token: token,
      customerId: customerId,
      languageId: languageId,
    );
  }
}
