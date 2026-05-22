import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import '../../../data/models/order/order_model.dart';
import '../../../data/models/payment/bakong_payment_model.dart';
import '../../../data/models/payment/payment_method_enum.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/payment_repository.dart';

// ─────────────────────────────────────────────────────────────
// Payment State Enum
// ─────────────────────────────────────────────────────────────

enum PaymentState {
  idle,
  creatingOrder,
  initiatingPayment,
  generatingQR,
  awaitingPayment, // QR displayed, polling active
  processingVerification,
  success,
  failed,
  cancelled,
  timeout,
}

// ─────────────────────────────────────────────────────────────
// TASK 14: PaymentController
// ─────────────────────────────────────────────────────────────

/// Manages the full payment lifecycle for both COD and Bakong flows.
///
/// State flow:
///   idle → creatingOrder → (COD) → success
///   idle → creatingOrder → initiatingPayment → generatingQR
///        → awaitingPayment → processingVerification → success
///        └→ failed / timeout / cancelled
///
/// Usage with Provider:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => PaymentController(),
///   child: PaymentMethodScreen(...),
/// )
/// ```
class PaymentController extends ChangeNotifier {
  final PaymentRepository _paymentRepository;
  final OrderRepository _orderRepository;

  PaymentController({
    PaymentRepository? paymentRepository,
    OrderRepository? orderRepository,
  }) : _paymentRepository = paymentRepository ?? PaymentRepository(),
       _orderRepository = orderRepository ?? OrderRepository();

  // ── State ─────────────────────────────────────────────────

  PaymentState _state = PaymentState.idle;
  PaymentMethod? _selectedPaymentMethod;
  OrderModel? _order;
  BakongPaymentModel? _bakongData;
  String? _errorMessage;
  int _pollingSeconds = 300; // 5 minutes
  int _pollAttempt = 0;

  // Double-submit guard
  bool _isProcessing = false;

  Timer? _pollingTimer;
  Timer? _countdownTimer;

  // ── Getters ───────────────────────────────────────────────

  PaymentState get state => _state;

  PaymentMethod? get selectedPaymentMethod => _selectedPaymentMethod;

  OrderModel? get order => _order;

  BakongPaymentModel? get bakongData => _bakongData;

  String? get errorMessage => _errorMessage;

  int get pollingSeconds => _pollingSeconds;

  bool get isProcessing => _isProcessing;

  bool get isLoading =>
      _state == PaymentState.creatingOrder ||
      _state == PaymentState.initiatingPayment ||
      _state == PaymentState.generatingQR ||
      _state == PaymentState.processingVerification;

  String get countdownDisplay {
    final m = (_pollingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_pollingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Payment Method Selection ──────────────────────────────

  void selectPaymentMethod(PaymentMethod method) {
    if (_selectedPaymentMethod == method) return;
    _selectedPaymentMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  // ── COD Flow ─────────────────────────────────────────────

  /// Creates a COD order and transitions to success state.
  Future<void> createCODOrder({
    required int userId,
    required int addressId,
    required String token,
  }) async {
    if (_isProcessing) return;
    if (_selectedPaymentMethod != PaymentMethod.cod) {
      _setError('Please select Cash on Delivery as payment method.');
      return;
    }

    _isProcessing = true;
    _setState(PaymentState.creatingOrder);

    try {
      final order = await _orderRepository.createCODOrder(
        userId: userId,
        addressId: addressId,
        token: token,
      );

      _order = order;
      _setState(PaymentState.success);
    } catch (e) {
      _setError('Failed to create order: ${_cleanError(e)}');
      _setState(PaymentState.failed);
    } finally {
      _isProcessing = false;
    }
  }

  Uint8List? _qrImageBytes;

  Uint8List? get qrImageBytes => _qrImageBytes;

  // ── Bakong Flow ───────────────────────────────────────────

  /// Full Bakong flow: create order → initiate → generate QR → poll.
  Future<void> startBakongPayment({
    required int userId,
    required int addressId,
    required String token,
  }) async {
    if (_isProcessing) return;

    _isProcessing = true;
    _errorMessage = null;

    try {
      // Step 1: Create Bakong order
      _setState(PaymentState.creatingOrder);
      final order = await _orderRepository.createBakongOrder(
        userId: userId,
        addressId: addressId,
        token: token,
      );
      _order = order;
      notifyListeners();

      // Step 2: Initiate payment (get QR string + md5)
      _setState(PaymentState.initiatingPayment);
      final bakong = await _paymentRepository.initiateBakongPayment(
        orderId: order.id,
        token: token,
      );
      _bakongData = bakong;
      notifyListeners();

      // Step 3: Generate QR image
      _setState(PaymentState.generatingQR);
      final qrWithImage = await _paymentRepository.generateQRImage(
        qr: bakong.qrString ?? '',
        md5: bakong.md5 ?? '',
        token: token,
      );
      _qrImageBytes = qrWithImage;
      notifyListeners();

      // Step 4: Start polling
      _setState(PaymentState.awaitingPayment);
      _startCountdown();
      _startPolling(token: token);
    } catch (e) {
      _setError('Payment setup failed: ${_cleanError(e)}');
      _setState(PaymentState.failed);
    } finally {
      _isProcessing = false;
    }
  }

  // ── Polling ───────────────────────────────────────────────

  void _startPolling({required String token}) {
    _pollAttempt = 0;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _pollTransaction(token: token);
    });
  }

  Future<void> _pollTransaction({required String token}) async {
    if (_state != PaymentState.awaitingPayment) return;
    if (_bakongData?.md5 == null) return;

    _pollAttempt++;

    try {
      final result = await _paymentRepository.checkTransaction(
        md5: _bakongData!.md5!,
        token: token,
      );

      final status = result['status'] as String? ?? '';

      if (status == 'SUCCESS') {
        _stopTimers();
        await _verifyPayment(
          transactionId: result['transaction_id'] as String? ?? '',
          token: token,
        );
      } else if (status == 'FAILED') {
        _stopTimers();
        _setError('Transaction failed. Please try again.');
        _setState(PaymentState.failed);
      }
      // PENDING — keep polling
    } catch (e) {
      debugPrint('PaymentController: poll attempt $_pollAttempt error: $e');
      // Don't fail on single poll error — keep trying until timeout
    }
  }

  Future<void> _verifyPayment({
    required String transactionId,
    required String token,
  }) async {
    _setState(PaymentState.processingVerification);

    try {
      final verified = await _paymentRepository.verifyPayment(
        orderId: _order!.id,
        transactionId: transactionId,
        token: token,
      );

      // Update order with verified status
      _order = _order?.copyWith(
        paymentVerified: true,
        verifiedAt: verified['verified_at'] as String?,
      );

      _setState(PaymentState.success);
    } catch (e) {
      _setError('Payment verification failed: ${_cleanError(e)}');
      _setState(PaymentState.failed);
    }
  }

  // ── Countdown Timer ───────────────────────────────────────

  void _startCountdown() {
    _pollingSeconds = 300;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pollingSeconds <= 0) {
        _stopTimers();
        _setError('Payment timed out. Please try again.');
        _setState(PaymentState.timeout);
        return;
      }
      _pollingSeconds--;
      notifyListeners();
    });
  }

  void _stopTimers() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer = null;
  }

  // ── Cancel ────────────────────────────────────────────────

  /// Cancels active polling and optionally cancels the order via API.
  Future<void> cancelPayment({int? userId, String? token}) async {
    _stopTimers();

    if (_order != null && userId != null && token != null) {
      try {
        await _orderRepository.cancelOrder(
          orderId: _order!.id,
          userId: userId,
          token: token,
        );
        _order = _order?.copyWith(status: null); // will be set by API response
      } catch (e) {
        debugPrint('PaymentController: cancel order error: $e');
      }
    }

    _setState(PaymentState.cancelled);
  }

  // ── Retry ─────────────────────────────────────────────────

  /// Resets state so the user can retry from scratch.
  void reset() {
    _stopTimers();
    _state = PaymentState.idle;
    _order = null;
    _bakongData = null;
    _errorMessage = null;
    _pollingSeconds = 300;
    _pollAttempt = 0;
    _isProcessing = false;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────

  void _setState(PaymentState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  String _cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}
