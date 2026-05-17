import 'package:flutter/foundation.dart';
import '../datasources/payment_service.dart';
import '../models/payment/bakong_payment_model.dart';

/// PaymentRepository handles payment-related business logic and wraps PaymentService
class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  /// Initiate Bakong payment and return QR/MD5 data
  /// 
  /// Wraps: PaymentService.initiateBakongPayment()
  /// Handles: Error logging, retries on network failure
  /// Returns: BakongPaymentModel with qr_string and md5
  Future<BakongPaymentModel> initiateBakongPayment({
    required int orderId,
    required String token,
    int retries = 3,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        debugPrint('[PaymentRepository] initiateBakongPayment attempt $attempt/$retries');
        final data = await _paymentService.initiateBakongPayment(
          orderId: orderId,
          token: token,
        );
        return BakongPaymentModel.fromJson(data);
      } catch (e) {
        debugPrint('[PaymentRepository] Attempt $attempt failed: $e');
        if (attempt == retries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempt * 2)); // Exponential backoff
      }
    }
    throw Exception('Failed to initiate Bakong payment after $retries attempts');
  }

  /// Generate QR image from QR string and MD5
  /// 
  /// Wraps: PaymentService.generateQRImage()
  /// Handles: Error logging, response parsing
  /// Returns: Map with qr_image (base64) and qr_url
  Future<BakongPaymentModel> generateQRImage({
    required String qr,
    required String md5,
    required String token,
  }) async {
    try {
      debugPrint('[PaymentRepository] generateQRImage');
      final data = await _paymentService.generateQRImage(
        qr: qr,
        md5: md5,
        token: token,
      );
      return BakongPaymentModel.fromJson(data);
    } catch (e) {
      debugPrint('[PaymentRepository] Error generating QR: $e');
      rethrow;
    }
  }

  /// Check transaction status by MD5
  /// 
  /// Wraps: PaymentService.checkTransaction()
  /// Handles: Status parsing, error handling
  /// Returns: Map with { status, transaction_id, amount }
  Future<Map<String, dynamic>> checkTransaction({
    required String md5,
    required String token,
  }) async {
    try {
      debugPrint('[PaymentRepository] checkTransaction');
      final data = await _paymentService.checkTransaction(
        md5: md5,
        token: token,
      );
      
      // Parse status value
      final status = data['status'] as String? ?? 'PENDING';
      debugPrint('[PaymentRepository] Transaction status: $status');
      
      return data;
    } catch (e) {
      debugPrint('[PaymentRepository] Error checking transaction: $e');
      rethrow;
    }
  }

  /// Verify payment after successful transaction
  /// 
  /// Wraps: PaymentService.verifyPayment()
  /// Handles: Error logging, response validation
  /// Returns: Map with verified order data
  Future<Map<String, dynamic>> verifyPayment({
    required int orderId,
    required String transactionId,
    required String token,
  }) async {
    try {
      debugPrint('[PaymentRepository] verifyPayment for order $orderId');
      final data = await _paymentService.verifyPayment(
        orderId: orderId,
        transactionId: transactionId,
        token: token,
      );
      
      final verified = data['payment_verified'] as bool? ?? false;
      debugPrint('[PaymentRepository] Payment verified: $verified');
      
      return data;
    } catch (e) {
      debugPrint('[PaymentRepository] Error verifying payment: $e');
      rethrow;
    }
  }

  /// Retry-enabled transaction check with exponential backoff
  /// 
  /// Polls checkTransaction with retries and delays
  /// Useful for waiting on delayed payment confirmations
  Future<Map<String, dynamic>> checkTransactionWithRetry({
    required String md5,
    required String token,
    int maxRetries = 12,
    int initialDelay = 5,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final result = await checkTransaction(md5: md5, token: token);
        final status = result['status'] as String? ?? 'PENDING';
        
        if (status == 'SUCCESS') {
          debugPrint('[PaymentRepository] Transaction successful on attempt $attempt');
          return result;
        }
        
        if (attempt < maxRetries) {
          final delay = initialDelay * attempt; // Linear delay: 5s, 10s, 15s...
          debugPrint('[PaymentRepository] Retry $attempt: waiting ${delay}s before next check');
          await Future.delayed(Duration(seconds: delay));
        }
      } catch (e) {
        debugPrint('[PaymentRepository] Retry $attempt failed: $e');
        if (attempt == maxRetries) {
          rethrow;
        }
        final delay = initialDelay * attempt;
        await Future.delayed(Duration(seconds: delay));
      }
    }
    throw Exception('Transaction check timeout after $maxRetries attempts');
  }
}

