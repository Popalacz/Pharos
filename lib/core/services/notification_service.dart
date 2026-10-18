
import 'package:pharos/core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pharos/core/network/http_client.dart';
import 'package:provider/provider.dart';
import 'package:pharos/main.dart';
import 'package:pharos/core/providers/orders_provider.dart';
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
        AppLog.d('Foreground notification: ${message.notification?.title}');
        _handleOrderUpdateNotification(message, openTrackingScreen: false);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    } catch (e) {
      AppLog.e('Notification Init Error: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    _handleOrderUpdateNotification(message, openTrackingScreen: true);
  }

  void _handleOrderUpdateNotification(
    RemoteMessage message, {
    required bool openTrackingScreen,
  }) {
    if (message.data['type'] != 'order_update' || message.data['order_id'] == null) {
      return;
    }

    final orderId = int.tryParse(message.data['order_id'].toString()) ?? 0;
    if (orderId <= 0) {
      return;
    }

    final context = navigatorKey.currentContext;
    context?.read<OrdersProvider>().fetchOrders();

    if (!openTrackingScreen) {
      final statusLabel = message.notification?.body ??
          message.data['status']?.toString() ??
          'Status zamówienia został zaktualizowany.';
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusLabel),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final orderRef = message.data['order_reference'] ?? '---';
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

  Future<void> syncTokenWithServer({
    required String token,
    int? customerId,
    int? languageId,
  }) async {
    try {
      _cachedToken = token;
      final dio = createHttpClient(baseUrl: ApiConfig.originUrl);
      final authToken = ApiService.authToken;
      if (authToken != null) {
        dio.options.headers['Authorization'] = 'Bearer $authToken';
      }

      await dio.post('/index.php', queryParameters: {
        'fc': 'module',
        'module': 'pharosapi',
        'controller': 'fcmtoken',
      }, data: {
        'token': token,
        'id_customer': customerId,
        'id_lang': languageId,
      });
      AppLog.d('FCM: Token synchronized for customer $customerId (lang: $languageId)');
    } catch (e) {
      AppLog.e('FCM: Failed to sync token: $e');
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
