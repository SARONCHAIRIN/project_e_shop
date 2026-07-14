import 'package:e_shop/Presentation/screen/order/orderSuccessScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:e_shop/data/repositories/payment_repository.dart';
import '../../../core/widgets/animation_widgets.dart';
import 'bakong_qr_screen.dart';
import 'payment_failed_screen.dart';

/// Screen that handles creating orders for COD and Bakong and directs to the
/// appropriate follow-up screen.
class PaymentProcessingScreen extends StatefulWidget {
  final int addressId;
  final double totalPrice;
  final String paymentMethod; // 'COD' or 'BAKONG'
  final OrderRepository orderRepository;
  final PaymentRepository paymentRepository;

  const PaymentProcessingScreen({
    super.key,
    required this.addressId,
    required this.totalPrice,
    required this.paymentMethod,
    required this.orderRepository,
    required this.paymentRepository,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isLoading = false;
  String? _error;

  // ✅ NEW: rotating status message so the user knows this can take a while
  String _statusMessage = 'Processing your order...';

  Future<void> _start() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _statusMessage = 'Processing your order...';
    });

    try {
      final storage = TokenStorage();
      final userId = await storage.getUserId();
      final token = await storage.getToken();

      if (userId == null || token == null) {
        throw Exception('User not authenticated');
      }

      if (widget.paymentMethod.toUpperCase() == 'COD') {
        final order = await widget.orderRepository.createCODOrder(
          userId: userId,
          addressId: widget.addressId,
          token: token,
          currency: 'KHR',
        );

        if (!mounted) return;
        Navigator.push(
          context,
          FadeSlideRoute(
            page: OrderSuccessScreen(
              paymentMethod: 'COD', // ✅ FIXED: was hardcoded 'BAKONG'
              orderId: order.id,
            ),
          ),
        );
      } else if (widget.paymentMethod.toUpperCase() == 'BAKONG') {
        // ✅ CHANGED: single call now returns qr_code + payment info directly.
        // No more separate initiateBakongPayment() call — that was
        // redundant and doubled the request time, which is what caused
        // the client-side timeouts.

        // Give the user a heads-up after a few seconds since the backend
        // can take 1-3 minutes to respond (Render free-tier cold starts).
        _showSlowServerHintAfterDelay();

        final order = await widget.orderRepository.createBakongOrder(
          userId: userId,
          addressId: widget.addressId,
          token: token,
        );

        if (!mounted) return;

        final qrCode = order.resolvedQrCode;
        if (qrCode.isEmpty) {
          throw Exception('Bakong order created but no QR code was returned');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BakongQrScreen(
              orderId: order.id,
              bakongQrString: order.resolvedQrCode,
              bakongMd5: order.transactionId ?? '',
              paymentUrl: order.paymentUrl ?? '',
              orderRepository: widget.orderRepository,
              paymentRepository: widget.paymentRepository,
            ),
          ),
        );
      } else {
        throw Exception('Unsupported payment method: ${widget.paymentMethod}');
      }
    } catch (e) {
      debugPrint('PaymentProcessing error: $e');
      setState(() => _error = e.toString());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaymentFailedScreen(reason: _error ?? 'Unknown error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Updates the status text if the request is still running after a delay,
  /// so the user doesn't think the app has frozen.
  void _showSlowServerHintAfterDelay() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        setState(() {
          _statusMessage =
          'Still working... this can take a minute or two.';
        });
      }
    });
    Future.delayed(const Duration(seconds: 40), () {
      if (mounted && _isLoading) {
        setState(() {
          _statusMessage =
          'Almost there — waking up the payment server, please wait.';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // start on next frame to let build show initial UI
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing Payment')),
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SpinKitCircle(color: Colors.blue, size: 48),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
            : _error != null
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _start,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}