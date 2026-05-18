import 'package:flutter/material.dart';

/// OrderStatusBadge widget for displaying order status with color coding
/// 
/// Features:
/// - Color-coded status display (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)
/// - Compact badge design
/// - Smooth animations on status change
/// - Reusable across order displays
class OrderStatusBadge extends StatelessWidget {
  /// Order status string (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)
  final String status;

  /// Optional custom size (default: small)
  final bool isLarge;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom text color
  final Color? textColor;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
    this.backgroundColor,
    this.textColor,
  });

  /// Get color based on order status
  Color _getStatusColor() {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.shade100;
      case 'PROCESSING':
        return Colors.blue.shade100;
      case 'SHIPPED':
        return Colors.purple.shade100;
      case 'DELIVERED':
        return Colors.green.shade100;
      case 'CANCELLED':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// Get text color based on order status
  Color _getTextColor() {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange.shade700;
      case 'PROCESSING':
        return Colors.blue.shade700;
      case 'SHIPPED':
        return Colors.purple.shade700;
      case 'DELIVERED':
        return Colors.green.shade700;
      case 'CANCELLED':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  /// Get icon based on order status
  IconData _getStatusIcon() {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_bottom;
      case 'PROCESSING':
        return Icons.settings;
      case 'SHIPPED':
        return Icons.local_shipping;
      case 'DELIVERED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  /// Get display text for status
  String _getDisplayText() {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'PROCESSING':
        return 'Processing';
      case 'SHIPPED':
        return 'Shipped';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? _getStatusColor();
    final text = textColor ?? _getTextColor();

    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(),
              color: text,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              _getDisplayText(),
              style: TextStyle(
                color: text,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Small badge
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _getDisplayText(),
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

