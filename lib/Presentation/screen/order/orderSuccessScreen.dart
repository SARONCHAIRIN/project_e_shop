import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:e_shop/Presentation/screen/Message_main_page/message_main.dart';
import 'package:e_shop/core/storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Presentation/controllers/order/order_controller.dart';

class OrderSuccessScreen extends StatefulWidget {
  final paymentMethod;
  final int orderId;
  const OrderSuccessScreen({
    super.key,
    required this.paymentMethod,
    required this.orderId,

  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync:    this,
      duration: Duration(milliseconds: 700),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve:  Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve:  Curves.easeIn,
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Spacer(),

              // ── Animated Check Icon ──
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width:  120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color:       Colors.blue.withOpacity(0.3),
                        blurRadius:  20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size:  64,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // ── Title ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Order Confirmed!',
                      style: TextStyle(
                        fontSize:   28,
                        fontWeight: FontWeight.bold,
                        color:      Colors.black,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Thank you for your purchase.\nWe are getting it ready for shipment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color:    Colors.grey[600],
                        height:   1.5,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // ── Order Info Card ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width:   double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:        Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon:  Icons.receipt_long_outlined,
                        label: 'Status',
                        value: 'PENDING',
                        valueColor: Colors.orange,
                      ),
                      Divider(height: 24),
                      _buildInfoRow(
                        icon:  Icons.local_shipping_outlined,
                        label: 'Delivery',
                        value: 'Processing',
                      ),
                      Divider(height: 24),
                      _buildInfoRow(
                        icon:  Icons.payment_outlined,
                        label: 'Payment',
                        value: 'Confirmed',
                        valueColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // ── Buttons ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [

                    // Track My Order
                    SizedBox(
                      width:  double.infinity,
                      height: 52,
                      child:
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to orders tab
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/trackorder',
                                (route) => false,
                            arguments: {'tab': 2}, // orders tab index
                          );
                        },
                        icon:  Icon(Icons.list_alt_outlined,
                            color: Colors.white),
                        label: Text(
                          'Track My Order',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.bold,
                            color:      Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Continue Shopping
                    SizedBox(
                      width:  double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/homemainppage',
                                (route) => false,

                          );
                        },
                        icon:  Icon(Icons.shopping_bag_outlined,
                            color: Colors.blue),
                        label: Text(
                          'Continue Shopping',
                          style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.bold,
                            color:      Colors.blue,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Cancel Order
                    SizedBox(
                      width:  double.infinity,
                      height: 52,
                      child: _buildCancelOrder(),
                    ),

                    // Need help
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => MessageMain()));
                      },
                      child: RichText(
                        text: TextSpan(
                          text:  'Need help? ',
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(

                              text:  'Contact Support',
                              style: TextStyle(
                                color:      Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Info Row ──
  Widget _buildInfoRow({
    required IconData icon,
    required String   label,
    required String   value,
    Color?            valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:        Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color:    Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize:   14,
            color:      valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelOrder() => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Cancel Order"),
            content: const Text("Are you sure you want to cancel this order?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No", style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes, Cancel", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );

        if (confirm == true) {
          final storage = TokenStorage();
          final token = await storage.readToken();
          final userId = await storage.readUserId();

          if (token == null || userId == null) return;

          await Provider.of<OrderController>(context, listen: false)
              .cancelOrder(userId, token, widget.orderId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Order cancelled successfully"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate back to orders tab after cancellation
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/divicenav',
                (route) => false,
            arguments: {'tab': 2}, // orders tab index
         );
        }
      },

      icon: const Icon(Icons.cancel_outlined, color: Colors.white),
      label: const Text(
        "Cancel Order",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );
}