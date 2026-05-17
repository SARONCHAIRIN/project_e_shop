import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// PaymentService handles all payment-related API calls (Bakong QR, verification, etc.)
class PaymentService {
  final Dio _dio;
  static const String _baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  PaymentService({Dio? dio}) : _dio = dio ?? Dio();

  /// Initiate Bakong payment for a given order
  /// 
  /// POST /api/v1/orders/{orderId}/bakong/initiate
  /// Returns: { qr_string, md5 }
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

  /// Generate QR image from QR string and MD5
  /// 
  /// POST /api/v1/bakong/get-qr-image
  /// Body: { qr, md5 }
  /// Returns: { qr_image (base64), qr_url }
  Future<Map<String, dynamic>> generateQRImage({
    required String qr,
    required String md5,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/bakong/get-qr-image',
        data: {'qr': qr, 'md5': md5},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[PaymentService] generateQRImage success');
        return data;
      }
      throw Exception('Failed to generate QR image: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  /// Check transaction status by MD5
  /// 
  /// POST /api/v1/bakong/check-transaction
  /// Body: { md5 }
  /// Returns: { status, transaction_id, amount }
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

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[PaymentService] checkTransaction: ${data['status']}');
        return data;
      }
      throw Exception('Failed to check transaction: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[PaymentService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      rethrow;
    }
  }

  /// Verify payment after successful transaction
  /// 
  /// POST /api/v1/orders/{orderId}/bakong/verify?transactionId={transactionId}
  /// Returns: { id, status, payment_verified, verified_at }
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

  /// Helper to handle Dio exceptions
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

