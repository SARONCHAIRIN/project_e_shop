import 'package:e_shop/core/storage/token_storage.dart';
import 'package:e_shop/data/models/order/order_model.dart';
import 'package:e_shop/data/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/animation_widgets.dart';
import 'order_history_screen.dart';

class OrderSuccessScreen extends ConsumerStatefulWidget {
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
  ConsumerState<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends ConsumerState<OrderSuccessScreen>
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

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$minute $period';
  }

  Future<bool> _showCancelBottomSheet() async {
    // Implement your cancel confirmation bottom sheet dialog here
    // Returning true for demonstration/template completion purposes
    return await showModalBottomSheet<bool>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cancel Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Are you sure you want to cancel this order?'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('No'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Yes, Cancel',
                          style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final hasOrder = widget.order != null;
    final statusText = hasOrder
        ? widget.order!.status.toString().split('.').last.toUpperCase()
        : 'CONFIRMED';
    final totalAmount = hasOrder
        ? '\$${widget.order!.totalAmount!.toStringAsFixed(2)}'
        : null;
    final displayOrderId = hasOrder
        ? widget.order!.id.toString()
        : widget.orderId.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F4),
      body: Center(
        // Constrains width on desktop/tablet platforms for proper web/desktop scaling
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    // Lottie confetti — behind content
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Lottie.asset(
                          'assets/animations/success_animetion.json',
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
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF32C787,
                                    ).withOpacity(0.12),
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

                            const SizedBox(height: 40),

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
                                      color: const Color(
                                        0xFF32C787,
                                      ).withOpacity(0.1),
                                    ),
                                  ),
                                  Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(
                                        0xFF32C787,
                                      ).withOpacity(0.18),
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
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
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
                                  const Text(
                                    'Thank you for your purchase.\nWe\'re getting it ready for shipment.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8A8A9A),
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
                                          horizontal: 18,
                                          vertical: 14,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1A1A2E),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.receipt_long_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
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
                                              valueColor:
                                                  statusText == 'CONFIRMED' ||
                                                      statusText == 'SUCCESS'
                                                  ? const Color(0xFF32C787)
                                                  : const Color(0xFFFF9500),
                                              valueBg:
                                                  statusText == 'CONFIRMED' ||
                                                      statusText == 'SUCCESS'
                                                  ? const Color(
                                                      0xFF32C787,
                                                    ).withOpacity(0.1)
                                                  : const Color(
                                                      0xFFFF9500,
                                                    ).withOpacity(0.1),
                                            ),
                                            _buildDivider(),
                                            _buildInfoRow(
                                              icon:
                                                  Icons.local_shipping_outlined,
                                              label: 'Delivery',
                                              value: 'Processing',
                                              valueColor: const Color(
                                                0xFF0066FF,
                                              ),
                                              valueBg: const Color(
                                                0xFF0066FF,
                                              ).withOpacity(0.08),
                                            ),
                                            _buildDivider(),
                                            _buildInfoRow(
                                              icon: Icons.payment_outlined,
                                              label: 'Payment',
                                              value:
                                                  widget.paymentMethod
                                                      ?.toString() ??
                                                  'Confirmed',
                                              valueColor: const Color(
                                                0xFF32C787,
                                              ),
                                              valueBg: const Color(
                                                0xFF32C787,
                                              ).withOpacity(0.1),
                                            ),
                                            if (totalAmount != null) ...[
                                              _buildDivider(),
                                              _buildInfoRow(
                                                icon:
                                                    Icons.attach_money_rounded,
                                                label: 'Total Amount',
                                                value: totalAmount,
                                                valueColor: const Color(
                                                  0xFF1A1A2E,
                                                ),
                                                valueBg: const Color(
                                                  0xFFF0F0F5,
                                                ),
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

                            const SizedBox(height: 20),

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
                                        onPressed: () async {
                                          final storage = TokenStorage();
                                          final token = await storage
                                              .readToken();
                                          final userId = await storage
                                              .readUserId();
                                          if (token == null || userId == null)
                                            return;

                                          if (!mounted) return;
                                          Navigator.pushNamed(
                                            context,
                                            '/trackMyOrder',
                                            arguments: {
                                              'orderId': widget.orderId,
                                              'userId': userId,
                                              'token': token,
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.local_shipping_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
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
                                          backgroundColor: const Color(
                                            0xFF1A1A2E,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
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
                                        icon: const Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Continue Shopping',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF1A1A2E,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE4E4EF),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    // View My Orders
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final storage = TokenStorage();
                                          final token = await storage
                                              .readToken();
                                          final userId = await storage
                                              .readUserId();
                                          if (token == null || userId == null)
                                            return;
                                          if (!mounted) return;

                                          Navigator.push(
                                            context,
                                            FadeSlideRoute(
                                              page: OrderHistoryScreen(
                                                userId: userId,
                                                token: token,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.receipt_long_outlined,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'View My Orders',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF1A1A2E,
                                          ),
                                          side: const BorderSide(
                                            color: Color(0xFFE4E4EF),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
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
                                            color: Color(0xFF8A8A9A),
                                            fontSize: 13,
                                          ),
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
              ],
            ),
          ),
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

      if (token == null || userId == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication information not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final repository = OrderRepository();
        await repository.cancelOrder(
          orderId: widget.orderId,
          userId: userId,
          token: token,
        );

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
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/divicenav',
          (route) => false,
          arguments: {'tab': 2},
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order\n$e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    },
    icon: const Icon(Icons.cancel_outlined, color: Color(0xFFFF3B30), size: 20),
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
      side: const BorderSide(color: Color(0xFFFFE0DE), width: 1.5),
      backgroundColor: const Color(0xFFFF3B30).withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
