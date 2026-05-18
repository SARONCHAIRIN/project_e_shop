import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../datasources/payment_service.dart';
import '../models/payment/bakong_payment_model.dart';

class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  /// Initiate Bakong payment — returns BakongPaymentModel with qrString + md5
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
        final model = BakongPaymentModel.fromJson(data);

        debugPrint('[PaymentRepository] Bakong Order created: #${model.orderId}');
        debugPrint('[PaymentRepository] qrString empty: ${model.qrString.isEmpty}');
        debugPrint('[PaymentRepository] md5 empty: ${model.md5.isEmpty}');

        return model;
      } catch (e) {
        debugPrint('[PaymentRepository] Attempt $attempt failed: $e');
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    throw Exception('Failed to initiate Bakong payment after $retries attempts');
  }

  /// Generate QR image — returns raw PNG bytes for Image.memory()
  Future<Uint8List> generateQRImage({
    required String qr,
    required String md5,
    required String token,
  }) async {
    if (qr.isEmpty || md5.isEmpty) {
      throw Exception('Cannot generate QR: qr or md5 is empty');
    }

    try {
      debugPrint('[PaymentRepository] generateQRImage');
      final bytes = await _paymentService.generateQRImage(
        qr: qr,
        md5: md5,
        token: token,
      );
      debugPrint('[PaymentRepository] QR image bytes received: ${bytes.length}');
      return bytes;
    } catch (e) {
      debugPrint('[PaymentRepository] Error generating QR: $e');
      rethrow;
    }
  }

  /// Check transaction status by MD5
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
      final status = data['status'] as String? ?? 'PENDING';
      debugPrint('[PaymentRepository] Transaction status: $status');
      return data;
    } catch (e) {
      debugPrint('[PaymentRepository] Error checking transaction: $e');
      rethrow;
    }
  }

  /// Verify payment after successful transaction
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

  /// Poll checkTransaction with linear backoff
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
          final delay = initialDelay * attempt;
          debugPrint('[PaymentRepository] Retry $attempt: waiting ${delay}s');
          await Future.delayed(Duration(seconds: delay));
        }
      } catch (e) {
        debugPrint('[PaymentRepository] Retry $attempt failed: $e');
        if (attempt == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: initialDelay * attempt));
      }
    }
    throw Exception('Transaction check timeout after $maxRetries attempts');
  }
}