import 'package:e_shop/Presentation/screen/order/reviewScreen.dart';
import 'package:flutter/material.dart';
class PaymentScreen extends StatefulWidget {
  final int userId;
  final String token;
  final int addressId;

  const PaymentScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.addressId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'CASH_ON_DELIVERY';

  final List<_PaymentMethod> _methods = [
    _PaymentMethod(
      id: 'CASH_ON_DELIVERY',
      label: 'Cash on Delivery',
      subtitle: 'Pay when you receive',
      icon: Icons.money_outlined,
    ),
    _PaymentMethod(
      id: 'ABA_PAY',
      label: 'ABA Pay',
      subtitle: 'Scan QR to pay',
      icon: Icons.qr_code_outlined,
    ),
    _PaymentMethod(
      id: 'CREDIT_CARD',
      label: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard',
      icon: Icons.credit_card_outlined,
    ),
  ];

  // Card form controllers (show only if CREDIT_CARD selected)
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvvCtrl        = TextEditingController();
  final _cardNameCtrl   = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _cardNameCtrl.dispose();
    super.dispose();
  }

  void _goToReview() {
    // Validate card fields if credit card selected
    if (_selectedMethod == 'CREDIT_CARD') {
      if (_cardNumberCtrl.text.isEmpty ||
          _expiryCtrl.text.isEmpty ||
          _cvvCtrl.text.isEmpty ||
          _cardNameCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all card details'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          userId:        widget.userId,
          token:         widget.token,
          addressId:     widget.addressId,
          paymentMethod: _selectedMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Payment Method'),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Step Indicator ──
            _buildStepIndicator(),
            SizedBox(height: 24),

            // ── Payment Methods ──
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            ..._methods.map((method) => _buildMethodCard(method)),

            // ── Credit Card Form ──
            if (_selectedMethod == 'CREDIT_CARD') ...[
              SizedBox(height: 20),
              _buildCardForm(),
            ],

            // ── ABA Pay QR placeholder ──
            if (_selectedMethod == 'ABA_PAY') ...[
              SizedBox(height: 20),
              _buildAbaPaySection(),
            ],

            SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: ElevatedButton(
          onPressed: _goToReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Continue to Review',
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

  // ── Step Indicator ──
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

  // ── Payment Method Card ──
  Widget _buildMethodCard(_PaymentMethod method) {
    final isSelected = _selectedMethod == method.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Radio dot
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              )
                  : null,
            ),

            SizedBox(width: 12),

            // Icon
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 22,
              ),
            ),

            SizedBox(width: 12),

            // Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    method.subtitle,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Credit Card Form ──
  Widget _buildCardForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 16),

          // Card Number
          _buildCardField(
            controller: _cardNumberCtrl,
            label: 'Card Number',
            hint: '0000 0000 0000 0000',
            icon: Icons.credit_card,
            keyboardType: TextInputType.number,
            maxLength: 19,
            onChanged: (val) {
              // Auto format: add space every 4 digits
              final digits = val.replaceAll(' ', '');
              final formatted = digits.replaceAllMapped(
                RegExp(r'.{4}'),
                    (m) => '${m.group(0)} ',
              ).trim();
              if (formatted != val) {
                _cardNumberCtrl.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(
                    offset: formatted.length,
                  ),
                );
              }
            },
          ),
          SizedBox(height: 12),

          // Expiry + CVV
          Row(
            children: [
              Expanded(
                child: _buildCardField(
                  controller: _expiryCtrl,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  onChanged: (val) {
                    // Auto insert slash after MM
                    if (val.length == 2 && !val.contains('/')) {
                      _expiryCtrl.text = '$val/';
                      _expiryCtrl.selection = TextSelection.collapsed(
                        offset: 3,
                      );
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildCardField(
                  controller: _cvvCtrl,
                  label: 'CVV',
                  hint: '123',
                  icon: Icons.lock_outline,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Cardholder Name
          _buildCardField(
            controller: _cardNameCtrl,
            label: 'Cardholder Name',
            hint: 'JOHN DOE',
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.characters,
          ),

          SizedBox(height: 12),

          // SSL note
          Row(
            children: [
              Icon(Icons.lock, size: 14, color: Colors.green),
              SizedBox(width: 4),
              Text(
                '256-bit SSL Encrypted',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ABA Pay Section ──
  Widget _buildAbaPaySection() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Icon(Icons.qr_code, size: 100, color: Colors.grey.shade400),
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/qr.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'QR code will be shown\nafter you place the order',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ── Reusable Card Field ──
  Widget _buildCardField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    bool obscureText = false,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── Payment Method Data Class ──
class _PaymentMethod {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;

  const _PaymentMethod({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}