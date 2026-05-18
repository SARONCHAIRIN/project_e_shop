import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/order/order_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSuccessScreen extends StatefulWidget {
  final paymentMethod;
  final int orderId;

  /// Optional: pass an OrderModel when coming from PaymentSuccessScreen flow
  final OrderModel? order;

  const OrderSuccessScreen({
    super.key,
    required this.paymentMethod,
    required this.orderId,
    this.order,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final String username = "chairin312007";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openTelegram() async {
    final Uri appUrl = Uri.parse("tg://resolve?domain=$username");
    final Uri webUrl = Uri.parse("https://t.me/$username");
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl);
    } else {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  String _formattedNow() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final hasOrder = widget.order != null;
    final statusText = hasOrder
        ? widget.order!.status.toString().split('.').last.toUpperCase()
        : 'CONFIRMED';
    final totalAmount = hasOrder
        ? '\$${widget.order!.totalAmount.toStringAsFixed(2)}'
        : null;
    final displayOrderId =
    hasOrder ? widget.order!.id.toString() : widget.orderId.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: Stack(
        children: [
          // Lottie confetti — behind content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/success_animetion.json',
                // height: MediaQuery.of(context).size.height * 0.25,
                height: 400,
                fit: BoxFit.fill,
                repeat: false,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Top bar ──
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF32C787).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF32C787),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Payment Verified',
                              style: TextStyle(
                                color: Color(0xFF32C787),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Space for lottie
                  // SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                  SizedBox(height: 40,),

                  // ── Check icon ──
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                            const Color(0xFF32C787).withOpacity(0.1),
                          ),
                        ),
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                            const Color(0xFF32C787).withOpacity(0.18),
                          ),
                        ),
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF32C787),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x4032C787),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Title ──
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Order Confirmed!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thank you for your purchase.\nWe\'re getting it ready for shipment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF8A8A9A),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Order Info Card ──
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Order header strip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Order #$displayOrderId',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formattedNow(),
                                    style: const TextStyle(
                                      color: Color(0xFF8A8AAA),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    icon: Icons.receipt_long_outlined,
                                    label: 'Status',
                                    value: statusText,
                                    valueColor: statusText == 'CONFIRMED' ||
                                        statusText == 'SUCCESS'
                                        ? const Color(0xFF32C787)
                                        : const Color(0xFFFF9500),
                                    valueBg: statusText == 'CONFIRMED' ||
                                        statusText == 'SUCCESS'
                                        ? const Color(0xFF32C787)
                                        .withOpacity(0.1)
                                        : const Color(0xFFFF9500)
                                        .withOpacity(0.1),
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    icon: Icons.local_shipping_outlined,
                                    label: 'Delivery',
                                    value: 'Processing',
                                    valueColor: const Color(0xFF0066FF),
                                    valueBg: const Color(0xFF0066FF)
                                        .withOpacity(0.08),
                                  ),
                                  _buildDivider(),
                                  _buildInfoRow(
                                    icon: Icons.payment_outlined,
                                    label: 'Payment',

                                    value: widget.paymentMethod?.toString() ??
                                        'Confirmed',
                                    valueColor: const Color(0xFF32C787),
                                    valueBg: const Color(0xFF32C787)
                                        .withOpacity(0.1),
                                  ),
                                  if (totalAmount != null) ...[
                                    _buildDivider(),
                                    _buildInfoRow(
                                      icon: Icons.attach_money_rounded,
                                      label: 'Total Amount',
                                      value: totalAmount,
                                      valueColor: const Color(0xFF1A1A2E),
                                      valueBg: const Color(0xFFF0F0F5),
                                      bold: true,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Buttons ──
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Track My Order
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/trackorder',
                                      (route) => false,
                                  arguments: {'tab': 2},
                                );
                              },
                              icon: const Icon(Icons.local_shipping_outlined,
                                  color: Colors.white, size: 20),
                              label: const Text(
                                'Track My Order',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A2E),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Continue Shopping
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/homemainppage',
                                      (route) => false,
                                );
                              },
                              icon: const Icon(Icons.shopping_bag_outlined,
                                  size: 20),
                              label: const Text(
                                'Continue Shopping',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1A1A2E),
                                side: const BorderSide(
                                    color: Color(0xFFE4E4EF), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Cancel Order
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: _buildCancelOrder(),
                          ),

                          // Need help
                          TextButton(
                            onPressed: _openTelegram,
                            child: RichText(
                              text: const TextSpan(
                                text: 'Need help? ',
                                style: TextStyle(
                                    color: Color(0xFF8A8A9A), fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: 'Contact Support',
                                    style: TextStyle(
                                      color: Color(0xFF0066FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, color: Color(0xFFF0F0F5)),
  );

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Color? valueBg,
    bool bold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0066FF), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8A9A),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: valueBg ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 15 : 13.5,
              color: valueColor ?? const Color(0xFF1A1A2E),
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelOrder() => OutlinedButton.icon(
    onPressed: () async {
      final confirmed = await _showCancelBottomSheet();
      if (!confirmed) return;

      final storage = TokenStorage();
      final token = await storage.readToken();
      final userId = await storage.readUserId();
      if (token == null || userId == null) return;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Order cancelled successfully'),
            ],
          ),
          backgroundColor: const Color(0xFF32C787),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/divicenav',
            (route) => false,
        arguments: {'tab': 2},
      );
    },
    icon: const Icon(Icons.cancel_outlined,
        color: Color(0xFFFF3B30), size: 20),
    label: const Text(
      'Cancel Order',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFFFF3B30),
        letterSpacing: -0.2,
      ),
    ),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFF3B30),
      side:
      const BorderSide(color: Color(0xFFFFE0DE), width: 1.5),
      backgroundColor:
      const Color(0xFFFF3B30).withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
  );

  Future<bool> _showCancelBottomSheet() async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color:
                const Color(0xFFFF3B30).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined,
                  color: Color(0xFFFF3B30), size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancel Order?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.\nAre you sure you want to cancel?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8A9A),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                          color: Color(0xFFE4E4EF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Keep Order',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Yes, Cancel',
                      style:
                      TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ) ??
        false;
  }
}