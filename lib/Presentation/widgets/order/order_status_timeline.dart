import 'package:flutter/material.dart';

/// OrderStatusTimeline displays the progression of order status
/// 
/// Features:
/// - Visual timeline showing all status stages
/// - Current status highlighted
/// - Completed steps marked with checkmark
/// - Smooth animations
/// - Responsive design
class OrderStatusTimeline extends StatelessWidget {
  /// Current order status (PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED)
  final String currentStatus;

  /// Optional timestamp for each status
  final Map<String, DateTime>? statusTimestamps;

  /// Size of status points
  final double pointSize;

  /// Optional custom colors
  final Color? activeColor;
  final Color? completedColor;
  final Color? pendingColor;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    this.statusTimestamps,
    this.pointSize = 20,
    this.activeColor,
    this.completedColor,
    this.pendingColor,
  });

  /// All possible statuses in order
  static const List<String> allStatuses = [
    'PENDING',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
  ];

  /// Get display name for status
  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Order Placed';
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

  /// Get icon for status
  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.shopping_cart_checkout;
      case 'PROCESSING':
        return Icons.hourglass_bottom;
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

  /// Check if status is completed
  bool _isCompleted(String status) {
    if (currentStatus.toUpperCase() == 'CANCELLED') {
      return status.toUpperCase() == 'PENDING' ||
          status.toUpperCase() == 'CANCELLED';
    }

    final currentIndex = allStatuses.indexOf(currentStatus.toUpperCase());
    final statusIndex = allStatuses.indexOf(status.toUpperCase());
    return statusIndex < currentIndex;
  }

  /// Check if status is current
  bool _isCurrent(String status) {
    return status.toUpperCase() == currentStatus.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayStatuses = currentStatus.toUpperCase() == 'CANCELLED'
        ? ['PENDING', 'CANCELLED']
        : allStatuses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayStatuses.length,
          itemBuilder: (context, index) {
            final status = displayStatuses[index];
            final isActive = _isCurrent(status);
            final isCompleted = _isCompleted(status);
            final isLast = index == displayStatuses.length - 1;
            final timestamp = statusTimestamps?[status];

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Point and Line
                Column(
                  children: [
                    // Status Point
                    Container(
                      width: pointSize,
                      height: pointSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? (completedColor ?? Colors.green)
                            : isActive
                                ? (activeColor ?? Colors.blue)
                                : (pendingColor ?? Colors.grey.shade300),
                        border: isActive
                            ? Border.all(
                                color: (activeColor ?? Colors.blue),
                                width: 3,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted ? Icons.check : _getStatusIcon(status),
                          color: isCompleted || isActive
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: pointSize * 0.5,
                        ),
                      ),
                    ),
                    // Connecting Line
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 80,
                        color: isCompleted
                            ? (completedColor ?? Colors.green)
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Status Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Label
                        Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive ? Colors.black : Colors.grey.shade700,
                          ),
                        ),
                        // Timestamp
                        if (timestamp != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatDateTime(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          )
                        else if (!isLast && !isCompleted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Format DateTime to readable string
  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at $hour:$minute';
  }
}

