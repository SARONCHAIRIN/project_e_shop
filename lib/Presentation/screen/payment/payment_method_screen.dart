import 'package:e_shop/Presentation/screen/payment/payment_processing_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../widgets/payment/payment_method_tile.dart';

/// PaymentMethodScreen allows user to select payment method (COD or Bakong)
class PaymentMethodScreen extends StatefulWidget {
  final double totalPrice;
  final int addressId;

  final String addressLine1;
  final String city;
  final String country;
  final String zipCode;
  final int? userId;
  final String? token;

  const PaymentMethodScreen({
    super.key,
    required this.totalPrice,
    required this.addressId,
    required this.addressLine1,
    required this.city,
    required this.country,
    required this.zipCode,

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

  @override
  void initState() {
    super.initState();
    _storage = TokenStorage();
    _initializeUserData();
  }



  Future<void> _initializeUserData() async {
    try {
      if (widget.userId != null && widget.token != null) {
        _userId = widget.userId!;
        _token = widget.token!;
      } else {
        final userId = await _storage.readUserId();
        final token = await _storage.readToken();
        print('user Id K : ${userId}');
        print('token K : $token');
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedPaymentMethod == null) {
      _showError('Please select a payment method');
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('[PaymentMethod] Selected: $_selectedPaymentMethod');
      debugPrint('[PaymentMethod] Address ID: ${widget.addressId}');
      debugPrint('[PaymentMethod] Total: \$${widget.totalPrice}');

      if (_selectedPaymentMethod == 'cod') {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentProcessingScreen(
              addressId: widget.addressId,
              totalPrice: widget.totalPrice,
              paymentMethod: 'COD',
              orderRepository: OrderRepository( ),           // inject your repository
              paymentRepository: PaymentRepository(),       // inject your repository
            ),
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proceeding with Cash on Delivery'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (_selectedPaymentMethod == 'bakong') {
        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => PaymentProcessingScreen(

              addressId: widget.addressId,

              totalPrice: widget.totalPrice,

              paymentMethod: 'BAKONG',

              orderRepository: OrderRepository(
              ),

              paymentRepository: PaymentRepository(),

            ),

          ),

        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proceeding with Bakong QR'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),

            _buildStepIndicator(),
            SizedBox(height: 20,),
            _buildAddressSection(),
            _buildOrderSummarySection(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PaymentMethodTile(
                    icon: Icons.local_atm,
                    title: 'Cash on Delivery',
                    description: 'Pay when you receive your order',
                    isSelected: _selectedPaymentMethod == 'cod',
                    onTap: () {
                      setState(() => _selectedPaymentMethod = 'cod');
                      setState(() => _errorMessage = null);


                    },
                    iconColor: Colors.orange,
                    selectedColor: Colors.orange.shade50,
                  ),
                  const SizedBox(height: 12),


                  PaymentMethodTile(
                    icon: Icons.qr_code,
                    title: 'Bakong QR Code',
                    description: 'Scan QR and pay instantly',
                    isSelected: _selectedPaymentMethod == 'bakong',
                    onTap: () {
                      setState(() => _selectedPaymentMethod = 'bakong');
                      setState(() => _errorMessage = null);

                    },
                    iconColor: Colors.purple,
                    selectedColor: Colors.purple.shade50,
                  ),
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
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
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
              Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.addressLine1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.city}, ${widget.country} ${widget.zipCode}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: Colors.blue.shade200,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
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

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleContinue,
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
    );
  }

  //buildIndicator
  Widget _buildStepIndicator() {
    final steps = ['Address', 'Payment', 'Review'];
    const current = 1; // Payment = index 1

    return Padding(
      padding:  EdgeInsets.only(
        left: 50,
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive  = i <= current;
          final isCurrent = i == current;

          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrent
                            ? Colors.blue
                            : Colors.grey,
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
                      margin: EdgeInsets.only(bottom: 16),
                      color: i < current
                          ? Colors.blue
                          : Colors.grey.shade300,
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

