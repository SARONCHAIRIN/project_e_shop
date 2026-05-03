import 'package:e_shop/Presentation/screen/order/orderSuccessScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cart/cart_item_model.dart';
import '../../../data/models/cart/cart_model.dart';
import '../../controllers/order/order_controller.dart';
import '../../controllers/cart/cart_controller.dart';

class ReviewScreen extends StatefulWidget {
  final int userId;
  final String token;
  final int addressId;
  final String paymentMethod;

  const ReviewScreen({
    super.key,
    required this.userId,
    required this.token,
    required this.addressId,
    required this.paymentMethod,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartController>().fetchCart(
        // widget.userId,
        // widget.token,
      );
    });
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'CASH_ON_DELIVERY': return 'Cash on Delivery';
      case 'ABA_PAY':          return 'ABA Pay';
      case 'CREDIT_CARD':      return 'Credit / Debit Card';
      default:                 return method;
    }
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'CASH_ON_DELIVERY': return Icons.money_outlined;
      case 'ABA_PAY':          return Icons.qr_code_outlined;
      case 'CREDIT_CARD':      return Icons.credit_card_outlined;
      default:                 return Icons.payment_outlined;
    }
  }

  void _placeOrder() async {
    final orderController = context.read<OrderController>();
    final cartController  = context.read<CartController>();

    //  ប្រើ checkout() ដែលមានក្នុង controller
    final success = await orderController.checkout(
      widget.userId,
      widget.token,
      widget.addressId,
      widget.paymentMethod,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    //  Clear cart
    cartController.clearCart();

    //  Navigate to success
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          paymentMethod: widget.paymentMethod,
        ),
      ),
          (route) => route.isFirst,
    );
  }
  @override
  Widget build(BuildContext context) {
    final cartController  = context.watch<CartController>();
    final orderController = context.watch<OrderController>();
    final cart            = cartController.cart;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Review Order',
          style: TextStyle(
            color:      Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),

      body: cartController.isLoading
          ? Center(child: SpinKitCircle(color: Colors.blue))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Step Indicator ──
            _buildStepIndicator(),
            SizedBox(height: 24),

            // ── Order Items ──
            _buildSectionTitle('Items Ordered'),
            SizedBox(height: 12),
            if (cart != null)
              ...cart.items.map((item) => _buildItemCard(item)),

            SizedBox(height: 20),

            // ── Delivery Address ──
            _buildSectionTitle('Delivery Address'),
            SizedBox(height: 12),
            _buildInfoCard(
              icon:  Icons.location_on_outlined,
              color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Address ID: ${widget.addressId}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize:   15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Deliver to saved address',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // ── Payment Method ──
            _buildSectionTitle('Payment Method'),
            SizedBox(height: 12),
            _buildInfoCard(
              icon:  _paymentIcon(widget.paymentMethod),
              color: Colors.green,
              child: Text(
                _formatPaymentMethod(widget.paymentMethod),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize:   15,
                ),
              ),
            ),

            SizedBox(height: 20),

            // ── Price Summary ──
            _buildSectionTitle('Price Summary'),
            SizedBox(height: 12),
            _buildPriceSummary(cart),

            SizedBox(height: 100),
          ],
        ),
      ),

      // ── Place Order Button ──
      bottomNavigationBar: Container(
        color:   Colors.white,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SSL note
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Secure 256-bit SSL Encrypted Payment',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Place Order button
            SizedBox(
              width:  double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: orderController.isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: orderController.isLoading
                    ? SpinKitCircle(color: Colors.white, size: 28)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Place Order',
                      style: TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.bold,
                        color:      Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step Indicator ──
  Widget _buildStepIndicator() {
    final steps   = ['Address', 'Payment', 'Review'];
    const current = 2;

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive  = i <= current;
        final isCurrent = i == current;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width:  12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    steps[i],
                    style: TextStyle(
                      fontSize:   10,
                      color:      isCurrent ? Colors.blue : Colors.grey,
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
    );
  }

  // ── Item Card ──
  Widget _buildItemCard(CartItem item) {
    return Container(
      margin:  EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle:  BlurStyle.outer,
            color:      Colors.blue.shade100,
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image ?? '',
              width:  70,
              height: 70,
              fit:    BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width:  70,
                height: 70,
                color:  Colors.grey.shade200,
                child:  Icon(Icons.image_not_supported),
              ),
            ),
          ),
          SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize:   14,
                  ),
                  maxLines:  2,
                  overflow:  TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${item.productSku.color} · Size ${item.productSku.size}',
                  style: TextStyle(
                    color:    Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    color:    Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Price
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize:   15,
              color:      Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ──
  Widget _buildInfoCard({
    required IconData icon,
    required Color    color,
    required Widget   child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle:  BlurStyle.outer,
            color:      Colors.blue.shade100,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ── Price Summary ──
  Widget _buildPriceSummary(CartModel? cart) {
    final subtotal = cart?.totalPrice ?? 0.0;
    const shipping = 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle:  BlurStyle.outer,
            color:      Colors.blue.shade100,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 8),
          _buildPriceRow(
            'Shipping',
            'Free',
            valueColor: Colors.green,
          ),
          SizedBox(height: 8),
          _buildPriceRow('Tax', 'Included'),
          Divider(height: 24),
          _buildPriceRow(
            'Total',
            '\$${(subtotal + shipping).toStringAsFixed(2)}',
            isBold:     true,
            valueColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      String label,
      String value, {
        bool   isBold     = false,
        Color? valueColor,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize:   isBold ? 16 : 14,
            color:      Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize:   isBold ? 16 : 14,
            color:      valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  // ── Section Title ──
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize:   16,
        fontWeight: FontWeight.bold,
        color:      Colors.black,
      ),
    );
  }
}