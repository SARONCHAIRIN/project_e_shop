import 'package:e_shop/Presentation/screen/payment/bakong_qr_screen.dart';
import 'package:e_shop/Presentation/screen/payment/payment_processing_screen.dart';
import 'package:e_shop/core/widgets/animation_widgets.dart';
import 'package:e_shop/data/datasources/adress/adress_service.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/loading_widgets.dart';
import '../../../data/models/address/address_model.dart';
import '../../../data/repositories/address/address_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../widgets/payment/payment_method_tile.dart';

/// PaymentMethodScreen allows user to select payment method (COD or Bakong)
class PaymentMethodScreen extends StatefulWidget {
  final double totalPrice;
  final int addressId;
  final int? userId;
  final String? token;

  const PaymentMethodScreen({
    super.key,
    required this.totalPrice,
    required this.addressId,
    this.userId,
    this.token,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? _selectedPaymentMethod;
  bool _isLoading = false;
  String? _errorMessage;
  late TokenStorage _storage;
  late int _userId;
  late String _token;

  AddressModel? _address;
  bool _loadingAddress = true;

  // ── Task 15: double-submit guard ──────────────────────────
  final _guard = SubmitGuard();

  final _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    _storage = TokenStorage();
    _initializeUserData().then((_) {
      _loadAddress();
    });
  }

  Future<void> _loadAddress() async {
    try {
      final repo = AddressRepository(AddressService());
      final address = await repo.getAddressById(userId: _userId, token: _token);
      setState(() {
        _address = address;
        _loadingAddress = false;
      });
    } catch (e) {
      debugPrint('Address load error: $e');
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _initializeUserData() async {
    try {
      if (widget.userId != null && widget.token != null) {
        _userId = widget.userId!;
        _token = widget.token!;
      } else {
        final userId = await _storage.readUserId();
        final token = await _storage.readToken();
        if (userId == null || token == null) {
          if (mounted) {
            _showError('Session expired. Please login again.');
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context);
            });
          }
          return;
        }
        _userId = userId;
        _token = token;
      }
    } catch (e) {
      _showError('Failed to initialize: $e');
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    // ── Task 15: replaced raw SnackBar with ErrorRecovery ──
    ErrorRecovery.showSnackBar(context, message);
  }

  // Future<void> _handleContinue() async {
  //   if (_selectedPaymentMethod == null) {
  //     _showError('Please select a payment method');
  //     return;
  //   }
  //   }

  // ── ៣. ហៅ shake() ពេល validation error ─────────────────────
  Future<void> _handleContinue() async {
    if (_selectedPaymentMethod == null) {
      _shakeKey.currentState?.shake(); // ← button shake!
      _showError('Please select a payment method');
      return;
    }

    // ── Task 15: SubmitGuard prevents double-tap ───────────
    await _guard.run(() async {
      setState(() => _isLoading = true);

      try {
        debugPrint('[PaymentMethod] Selected: $_selectedPaymentMethod');
        debugPrint('[PaymentMethod] Address ID: ${widget.addressId}');
        debugPrint('[PaymentMethod] Total: \$${widget.totalPrice}');

        // ══════════════════════════════════════════════════
        // COD FLOW
        // ══════════════════════════════════════════════════
        if (_selectedPaymentMethod == 'cod') {
          final orderRepository = OrderRepository();
          final paymentRepository = PaymentRepository();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentProcessingScreen(
                addressId: widget.addressId,
                totalPrice: widget.totalPrice,
                paymentMethod: 'COD',
                orderRepository: orderRepository,
                paymentRepository: paymentRepository,
              ),
            ),
          );

          // if (mounted) {
          //   ErrorRecovery.showSuccess(
          //     context,
          //     'Proceeding with Cash on Delivery',
          //   );
          // }
        }
        // ══════════════════════════════════════════════════
        // BAKONG FLOW
        // ══════════════════════════════════════════════════
        else if (_selectedPaymentMethod == 'bakong') {
          final orderRepository = OrderRepository();
          final paymentRepository = PaymentRepository();

          // 1. Create Bakong Order — with 30s timeout
          final order = await withTimeout(
            future: orderRepository.createBakongOrder(
              userId: _userId,
              addressId: widget.addressId,
              token: _token,
            ),
            duration: const Duration(seconds: 30),
            timeoutMessage: 'Order creation timed out. Please try again.',
          );

          final int orderId = order.id;

          // 2. Initiate Bakong Payment — with 20s timeout
          final paymentData = await withTimeout(
            future: paymentRepository.initiateBakongPayment(
              orderId: orderId,
              token: _token,
            ),
            duration: const Duration(seconds: 20),
            timeoutMessage: 'Bakong service timed out. Please try again.',
          );

          if (paymentData == null || paymentData.qrString.isEmpty) {
            _showError('Bakong service unavailable. Please try again later.');
            return;
          }

          final String bakongQrString = paymentData.qrString;
          final String bakongMd5 = paymentData.md5;

          final uri = Uri(
            scheme: 'bakong',
            host: 'pay',
            queryParameters: {'qr': bakongQrString},
          );
          final String paymentUrl = uri.toString();

          debugPrint('Order ID: $orderId');
          debugPrint('QR String: $bakongQrString');
          debugPrint('MD5: $bakongMd5');

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BakongQrScreen(
                orderId: orderId,
                bakongQrString: bakongQrString,
                paymentUrl: paymentUrl,
                bakongMd5: bakongMd5,
                orderRepository: orderRepository,
                paymentRepository: paymentRepository,
              ),
            ),
          );

          // if (mounted) {
          //   ErrorRecovery.showSuccess(context, 'Proceeding with Bakong QR');
          // }
        }
      } catch (e) {
        debugPrint('Payment Error: $e');

        // ── Task 15: modal dialog with retry on error ──────
        if (mounted) {
          await ErrorRecovery.show(
            context: context,
            message: e.toString().replaceFirst('Exception: ', ''),
            onRetry: _handleContinue,
            retryLabel: 'Try Again',
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Select Payment Method'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),

      // ── LoadingOverlay រុំ body ទាំងមូល ──────────────────────
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _selectedPaymentMethod == 'bakong'
            ? 'Creating QR Code...'
            : 'Creating Order',
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildStepIndicator(),
              const SizedBox(height: 20),
              _buildAddressSection(),
              _buildOrderSummarySection(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── InteractionDisabler dim tiles when processing ──
                    InteractionDisabler(
                      disabled: _isLoading || _guard.isRunning,
                      child: Column(
                        children: [
                          PaymentMethodTile(
                            icon: Icons.local_atm,
                            title: 'Cash on Delivery',
                            description: 'Pay when you receive your order',
                            isSelected: _selectedPaymentMethod == 'cod',
                            onTap: () => setState(() {
                              _selectedPaymentMethod = 'cod';
                              _errorMessage = null;
                            }),
                            iconColor: Colors.orange,
                            selectedColor: Colors.orange.shade50,
                          ),
                          const SizedBox(height: 12),

                          PaymentMethodTile(
                            icon: Icons.qr_code,
                            title: 'Bakong QR Code',
                            description: 'Scan QR and pay instantly',
                            isSelected: _selectedPaymentMethod == 'bakong',
                            onTap: () => setState(() {
                              _selectedPaymentMethod = 'bakong';
                              _errorMessage = null;
                            }),
                            iconColor: Colors.purple,
                            selectedColor: Colors.purple.shade50,
                          ),
                        ],
                      ),
                    ),

                    // ─────────────────────────────────────────────────
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_loadingAddress)
                        const Text('Loading address...')
                      else if (_address == null)
                        const Text('No address found')
                      else ...[
                        Text(
                          _address!.addressline1 ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_address!.city ?? ''}, ${_address!.country ?? ''} ${_address!.zipcode ?? ''}',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit Cart',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.blue.shade200, thickness: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              Text(
                '\$${widget.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ១. declare key នៅក្នុង State ────────────────────────────
  // final _shakeKey = GlobalKey<ShakeWidgetState>();

  // ── ២. _buildBottomButton ────────────────────────────────────
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ShakeWidget(
        // ← រុំ button
        key: _shakeKey,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: (_isLoading || _guard.isRunning)
                ? null
                : _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Continue to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Address', 'Payment'];
    final width = MediaQuery.of(context).size.width;
    const current = 1;

    return Padding(
      padding: EdgeInsets.only(left: width * 0.25),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i <= current;
          final isCurrent = i == current;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrent ? Colors.blue : Colors.grey,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 1.5,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: i < current ? Colors.blue : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
