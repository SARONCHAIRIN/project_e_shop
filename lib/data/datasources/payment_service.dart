import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final Dio _dio;
  static const String _baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  // angkor home
  // static const String _baseUrl = 'http://192.168.18.61:8080/api/v1';

  // rupp ip
  // static const String _baseUrl = 'http://10.1.121.208:8080/api/v1';

  // static const String _baseUrl = 'http://localhost:8080/api/v1';

  PaymentService({Dio? dio}) : _dio = dio ?? Dio();

  /// POST /api/v1/orders/{orderId}/bakong/initiate
  Future<Map<String, dynamic>> initiateBakongPayment({
    required int orderId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        // '$_baseUrl/orders/bakong/initiate',
        '$_baseUrl/orders/bakong/initiate',
        // '$_baseUrlwifi/orders/bakong/initiate',
        queryParameters: {'orderId': orderId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[PaymentService] initiateBakongPayment success: $data');
        return data;
      }
      throw Exception(
        'Failed to initiate Bakong payment: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  Future<Uint8List> generateQRImage({
    required String qr,
    required String md5,
    required String token,
  }) async {
    if (qr.isEmpty || md5.isEmpty) {
      throw Exception('QR string and MD5 must not be empty');
    }

    try {
      final payload = {'qr': qr, 'md5': md5};
      debugPrint(
        '[PaymentService] generateQRImage request payload keys: ${payload.keys}',
      );

      final response = await _dio.post(
        '$_baseUrl/bakong/get-qr-image',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes, //  raw PNG bytes
        ),
      );

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data as List<int>);
        debugPrint(
          '[PaymentService] generateQRImage success, bytes: ${bytes.length}',
        );
        return bytes;
      }

      throw Exception('Error ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/bakong/check-transaction
  Future<Map<String, dynamic>> checkTransaction({
    required String md5,
    required String token,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/bakong/check-transaction',
      data: {"md5": md5},
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ),
    );

    final raw = response.data;

    debugPrint("CHECK RESPONSE => $raw");

    if (raw["responseCode"] == 0) {
      final data = raw["data"];

      return {
        "status": "SUCCESS",

        "transactionId": data["hash"],

        "amount": data["amount"],
      };
    }

    return {"status": "PENDING"};
  }

  /// POST /api/v1/orders/bakong/verify?orderId={orderId}&transactionId={transactionId}
  Future<Map<String, dynamic>> verifyPayment({
    required int orderId,
    required String transactionId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/orders/bakong/verify',

        queryParameters: {'orderId': orderId, 'transactionId': transactionId},

        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('[PaymentService] verify URL => ${response.realUri}');

      debugPrint('[PaymentService] verify response => ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;

        debugPrint('[PaymentService] verifyPayment success: $data');

        return data;
      }

      throw Exception('Failed to verify payment: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');

      debugPrint('[PaymentService] Response: ${e.response?.data}');

      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');

      rethrow;
    }
  }

  Exception _handleError(DioException e) {
    String message = 'Network error';

    if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Response timeout';
    } else if (e.response != null) {
      //  Try to extract the backend's actual error message from the body
      final data = e.response?.data;
      String? backendMessage;
      if (data is Map) {
        backendMessage = data['message'] as String? ?? data['error'] as String?;
      }
      message = backendMessage != null
          ? 'Error ${e.response?.statusCode}: $backendMessage'
          : 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}';

      debugPrint('[OrderService] Full error response: ${e.response?.data}');
    }

    return Exception(message);
  }
}
