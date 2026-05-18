import 'package:flutter/material.dart';
import '../payment/payment_status_badge.dart';

/// OrderCard widget displays a single order in a list
/// 
/// Features:
/// - Display Order ID, Status, Total Price, Date
/// - Status badge with color coding
/// - Tap to view order detail
/// - Item count preview
/// - Smooth animations
class OrderCard extends StatelessWidget {
  /// Order ID
  final int orderId;

  /// Order status (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)
  final String status;

  /// Total order price
  final double totalPrice;

  /// Order creation date
  final DateTime createdDate;

  /// Number of items in order
  final int itemCount;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Optional custom background color
  final Color? backgroundColor;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.status,
    required this.totalPrice,
    required this.createdDate,
    required this.itemCount,
    this.onTap,
    this.backgroundColor,
  });

  /// Format currency
  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$orderId',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                OrderStatusBadge(
                  status: status,
                  isLarge: false,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Date and Item Count
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.grey.shade500,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(createdDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 24),
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey.shade500,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$itemCount item${itemCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(
              color: Colors.grey.shade200,
              height: 12,
              thickness: 1,
            ),

            // Footer: Total Price and Arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(totalPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

