import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 Permission: ${settings.authorizationStatus}');

    if (Platform.isIOS || Platform.isMacOS) {
      String? apnsToken;

      // Wait a little for APNs registration
      for (int i = 0; i < 10; i++) {
        apnsToken = await _messaging.getAPNSToken();

        if (apnsToken != null) {
          break;
        }

        print('⏳ Waiting for APNs token...');
        await Future.delayed(const Duration(seconds: 1));
      }

      if (apnsToken == null) {
        print('❌ APNs token is not available.');
        print('📱 Test FCM using a physical iPhone.');
        return;
      }

      print('🍎 APNs Token: $apnsToken');
    }

    try {
      final fcmToken = await _messaging.getToken();

      print('');
      print('========================================');
      print('🔥 REAL FCM TOKEN');
      print(fcmToken);
      print('========================================');
      print('');
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 FCM MESSAGE RECEIVED');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification opened');
      print('Data: ${message.data}');
    });

    _messaging.onTokenRefresh.listen((token) {
      print('🔄 FCM TOKEN REFRESHED');
      print(token);
    });
  }
}