import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DeviceTokenService {
  DeviceTokenService({
    required this.dio,
  });

  final Dio dio;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> registerDeviceToken({
    required String accessToken,
  }) async {
    try {
      // Ask notification permission
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final fcmToken = await _messaging.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ FCM token is empty');
        return;
      }

      final platform = Platform.isAndroid
          ? 'android'
          : Platform.isIOS
          ? 'ios'
          : 'unknown';

      final response = await dio.post(
        '/api/v1/device-tokens',
        data: {
          'token': fcmToken.trim(),
          'platform': platform,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('✅ Device token registered');
      print(response.data);
    } catch (e) {
      // Do not fail login just because notification registration failed
      print('❌ Device token registration failed: $e');
    }
  }
}