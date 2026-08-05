import 'package:e_shop/Presentation/screen/payment/bakong_qr_screen.dart';
import 'package:e_shop/Presentation/screen/payment/payment_processing_screen.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/order/order_model.dart';
import 'package:e_shop/data/repositories/address/address_repository.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:e_shop/data/repositories/payment_repository.dart';
import 'package:e_shop/provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopCheckout extends ConsumerStatefulWidget {
  final int userId;
  final String token;
  final int? addressId;
  final AddressRepository repo;
  final TokenStorage storage;

  const DesktopCheckout({
    super.key,
    required this.userId,
    required this.token,
    this.addressId,
    required this.repo,
    required this.storage,
  });

  @override
  ConsumerState<DesktopCheckout> createState() => _DesktopCheckoutState();
}

class _DesktopCheckoutState extends ConsumerState<DesktopCheckout> {
  // ================= ADDRESS CONTROLLERS =================
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final zipController = TextEditingController();

  int? addressId;
  bool loadingAddress = true;
  bool editingAddress = false;

  // ================= PAYMENT =================
  String? selectedPayment = 'bakong'; // Default selection for better UX
  bool loading = false;

  final OrderRepository orderRepository = OrderRepository();
  final PaymentRepository paymentRepository = PaymentRepository();

  // Design tokens
  static const Color _primaryBlue = Color(0xFF0066FF);
  static const Color _bgScreen = Color(0xFFF7F9FC);
  static const Color _cardBg = Colors.white;
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textMuted = Color(0xFF7A7A9D);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    addressId = widget.addressId;
    _loadExistingAddress();
  }

  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    zipController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAddress() async {
    try {
      final address = await widget.repo.getAddressById(
        userId: widget.userId,
        token: widget.token,
      );

      if (address != null && mounted) {
        setState(() {
          addressId = address.id;
          addressController.text = address.addressline1;
          cityController.text = address.city;
          countryController.text = address.country;
          zipController.text = address.zipcode;
          editingAddress = true;
          loadingAddress = false;
        });
      } else if (mounted) {
        setState(() {
          loadingAddress = false;
        });
      }
    } catch (e) {
      debugPrint("Load address error $e");
      if (mounted) {
        setState(() {
          loadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final total = cartState.cart?.totalPrice ?? 0;

    return Scaffold(
      backgroundColor: _bgScreen,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1300),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navigation / Title Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Secure Checkout",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Complete your shipping address and payment details",
                        style: TextStyle(
                          fontSize: 14,
                          color: _textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Main Workspace Layout
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT: ADDRESS SECTION (65%)
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _addressSection(),
                            const SizedBox(height: 24),
                            _securityBadgeCard(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 32),

                    // RIGHT: SUMMARY & PAYMENT (35%)
                    Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _orderSummary(total),
                            const SizedBox(height: 24),
                            _paymentSection(total),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ADDRESS SECTION =================
  Widget _addressSection() {
    if (loadingAddress) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: _primaryBlue),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: _primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    editingAddress ? "Shipping Address" : "New Shipping Address",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              if (editingAddress)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Default Saved",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _textField(
            controller: addressController,
            label: "Street Address / Building / Apt",
            icon: Icons.home_outlined,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: cityController,
                  label: "City",
                  icon: Icons.location_city_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _textField(
                  controller: zipController,
                  label: "Postal Code / Zip",
                  icon: Icons.pin_drop_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _textField(
            controller: countryController,
            label: "Country",
            icon: Icons.public_rounded,
          ),
        ],
      ),
    );
  }

  // ================= ORDER SUMMARY =================
  Widget _orderSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 20),
          _summaryRow("Subtotal", "\$${total.toStringAsFixed(2)}"),
          const SizedBox(height: 4),
          _summaryRow("Shipping Fee", "FREE", isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: _borderColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isFree ? Colors.green : _textDark,
          ),
        ),
      ],
    );
  }

  // ================= PAYMENT SECTION =================
  Widget _paymentSection(double total) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Payment Method",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 18),

          // Professional Custom Radio Choice Cards
          _paymentOptionTile(
            id: "bakong",
            title: "Bakong KHQR",
            subtitle: "Instant scan & pay via mobile banking",
            iconWidget: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_bakong.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.qr_code_2_rounded,
                    color: _primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _paymentOptionTile(
            id: "cod",
            title: "Cash on Delivery",
            subtitle: "Pay securely upon receiving your items",
            iconWidget: const Icon(
              Icons.local_atm_rounded,
              color: Colors.green,
              size: 22,
            ),
          ),

          const SizedBox(height: 24),

          // Modern Primary Action Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : _payNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: _primaryBlue.withOpacity(0.4),
              ),
              child: loading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Proceed to Pay \$${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOptionTile({
    required String id,
    required String title,
    required String subtitle,
    required Widget iconWidget,
  }) {
    final isSelected = selectedPayment == id;

    return InkWell(
      onTap: () => setState(() => selectedPayment = id),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryBlue : _borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primaryBlue.withOpacity(0.12)
                    : _bgScreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: iconWidget,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _textDark : _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: selectedPayment,
              activeColor: _primaryBlue,
              onChanged: (val) => setState(() => selectedPayment = val),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECURITY BADGE =================
  Widget _securityBadgeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Colors.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Guaranteed Safe & Secure",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Your personal and financial data is encrypted and protected.",
                  style: TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= MODERN TEXT FIELD =================
  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, color: _textMuted, size: 20),
        filled: true,
        fillColor: _bgScreen,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _borderColor.withOpacity(0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  // ================= PAY NOW LOGIC =================
  Future<void> _payNow() async {
    if (addressId == null) {
      _showMessage("Delivery address not found", isError: true);
      return;
    }

    if (addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        zipController.text.trim().isEmpty) {
      _showMessage("Please complete all address fields", isError: true);
      return;
    }

    if (selectedPayment == null) {
      _showMessage("Please select a payment method", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      final cartState = ref.read(cartControllerProvider);
      final total = cartState.cart?.totalPrice ?? 0;

      if (selectedPayment == "cod") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentProcessingScreen(
              addressId: addressId!,
              totalPrice: total,
              paymentMethod: "COD",
              orderRepository: orderRepository,
              paymentRepository: paymentRepository,
            ),
          ),
        );
      } else if (selectedPayment == "bakong") {
        final OrderModel order = await orderRepository.createBakongOrder(
          userId: widget.userId,
          addressId: addressId!,
          token: widget.token,
        );

        if (order.resolvedQrCode.isEmpty) {
          _showMessage("Bakong QR code unavailable", isError: true);
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BakongQrScreen(
              orderId: order.id,
              bakongQrString: order.resolvedQrCode,
              paymentUrl: order.resolvedQrCode,
              bakongMd5: order.transactionId ?? "",
              orderRepository: orderRepository,
              paymentRepository: paymentRepository,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Payment error: $e");
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}