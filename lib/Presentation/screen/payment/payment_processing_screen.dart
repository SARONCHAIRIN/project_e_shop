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
/// appropriate follow-up screen with a modern, high-end loading UX.
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

  String _statusMessage = 'Securing your transaction...';
  String _statusSubtitle =
      'Please keep this window open while we set up your order.';

  // Modern design tokens
  static const Color _primaryBlue = Color(0xFF0066FF);
  static const Color _bgScreen = Color(0xFFF7F9FC);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF7A7A9D);
  static const Color _borderColor = Color(0xFFE2E8F0);

  Future<void> _start() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _statusMessage = 'Securing your transaction...';
      _statusSubtitle =
          'Please keep this window open while we set up your order.';
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
            page: OrderSuccessScreen(paymentMethod: 'COD', orderId: order.id),
          ),
        );
      } else if (widget.paymentMethod.toUpperCase() == 'BAKONG') {
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

  void _showSlowServerHintAfterDelay() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isLoading) {
        setState(() {
          _statusMessage = 'Connecting to Payment Gateway...';
          _statusSubtitle =
              'This can take a moment depending on network speed.';
        });
      }
    });
    Future.delayed(const Duration(seconds: 40), () {
      if (mounted && _isLoading) {
        setState(() {
          _statusMessage = 'Finalizing secure connection...';
          _statusSubtitle =
              'Waking up secure servers, thank you for your patience.';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScreen,
      appBar: AppBar(
        backgroundColor: _bgScreen,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Processing Payment',
          style: TextStyle(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: _borderColor.withOpacity(0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const SpinKitFadingCircle(
                      color: _primaryBlue,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _statusSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ] else if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Transaction Failed',
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? 'An unexpected error occurred.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox.shrink(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
