import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final Dio _dio;
  static const String _baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  PaymentService({Dio? dio}) : _dio = dio ?? Dio();

  /// POST /api/v1/orders/{orderId}/bakong/initiate
  Future<Map<String, dynamic>> initiateBakongPayment({
    required int orderId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/orders/$orderId/bakong/initiate',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[PaymentService] initiateBakongPayment success: $data');
        return data;
      }
      throw Exception('Failed to initiate Bakong payment: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/bakong/get-qr-image
  /// Server returns raw PNG bytes
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
      debugPrint('[PaymentService] generateQRImage request payload keys: ${payload.keys}');

      final response = await _dio.post(
        '$_baseUrl/bakong/get-qr-image',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes, // ✅ raw PNG bytes
        ),
      );

      if (response.statusCode == 200) {
        final bytes = Uint8List.fromList(response.data as List<int>);
        debugPrint('[PaymentService] generateQRImage success, bytes: ${bytes.length}');
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
    try {
      final response = await _dio.post(
        '$_baseUrl/bakong/check-transaction',
        data: {'md5': md5},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint('[PaymentService] checkTransaction status: ${response.statusCode}');
      debugPrint('[PaymentService] checkTransaction raw: ${response.data}');

      if (response.statusCode == 200) {
        final raw = response.data;

        // data is a Map with nested 'data' key
        if (raw is Map<String, dynamic>) {
          final inner = raw['data'];

          // ✅ data: { status: ... }
          if (inner is Map<String, dynamic>) {
            debugPrint('[PaymentService] checkTransaction status: ${inner['status']}');
            return inner;
          }

          // ✅ data: null = still pending, don't crash
          if (inner == null) {
            debugPrint('[PaymentService] checkTransaction: data=null → PENDING');
            return {'status': 'PENDING'};
          }
        }

        // ✅ Fallback
        return {'status': 'PENDING'};
      }

      throw Exception('Failed to check transaction: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] checkTransaction DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] checkTransaction Error: $e');
      rethrow;
    }
  }

  /// POST /api/v1/orders/{orderId}/bakong/verify?transactionId={transactionId}
  Future<Map<String, dynamic>> verifyPayment({
    required int orderId,
    required String transactionId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/orders/$orderId/bakong/verify',
        queryParameters: {'transactionId': transactionId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[PaymentService] verifyPayment success');
        return data;
      }
      throw Exception('Failed to verify payment: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');
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
      message = 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}';
    }
    return Exception(message);
  }
}