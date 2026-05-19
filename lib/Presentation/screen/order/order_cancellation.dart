import 'package:flutter/material.dart';
import '../../../data/models/order/order_model.dart';
import '../../../data/models/order/order_status_enum.dart';
import '../../../data/repositories/order_repository.dart';

/// TASK 13: Order Cancellation System
///
/// Provides:
/// 1. [OrderCancellationHandler] — business logic mixin for any screen/controller
/// 2. [CancelOrderButton]        — drop-in cancel button widget (validates PENDING)
/// 3. [CancelOrderDialog]        — standalone confirmation dialog widget
/// 4. [OrderCancellationService] — static utility to call from controllers
///
/// Usage pattern:
///   - Mix [OrderCancellationHandler] into a State class to get _cancelOrder()
///   - Or use static [OrderCancellationService.cancel()] from a controller
///   - Drop in [CancelOrderButton] anywhere you need a cancel button

// ─────────────────────────────────────────────
// 1. Business Logic Mixin
// ─────────────────────────────────────────────

/// Mixin providing cancel order logic with confirmation, API call,
/// error handling, and state tracking.
///
/// To use: mix into a State and call [cancelOrderWithConfirmation].
mixin OrderCancellationHandler<T extends StatefulWidget> on State<T> {
  final OrderRepository _cancelRepo = OrderRepository();
  bool _isCancellingOrder = false;

  bool get isCancellingOrder => _isCancellingOrder;

  /// Shows confirmation dialog, then calls cancel API if confirmed.
  ///
  /// [order] — the order to cancel (must be PENDING)
  /// [userId] — the authenticated user ID
  /// [token] — bearer token
  /// [onSuccess] — called after successful cancellation with updated order
  /// [onError] — called when cancellation fails
  Future<void> cancelOrderWithConfirmation({
    required BuildContext context,
    required OrderModel order,
    required int userId,
    required String token,
    void Function(OrderModel cancelledOrder)? onSuccess,
    void Function(String error)? onError,
  }) async {
    // Guard: only allow cancellation of PENDING orders
    if (order.status != OrderStatus.pending) {
      _showSnackBar(
        context,
        message: 'Only pending orders can be cancelled.',
        isError: true,
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CancelOrderDialog(order: order),
    );

    if (confirmed != true) return;

    // Execute cancellation
    await _executeCancellation(
      context: context,
      order: order,
      userId: userId,
      token: token,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> _executeCancellation({
    required BuildContext context,
    required OrderModel order,
    required int userId,
    required String token,
    void Function(OrderModel cancelledOrder)? onSuccess,
    void Function(String error)? onError,
  }) async {
    if (_isCancellingOrder) return;
    if (!mounted) return;

    setState(() => _isCancellingOrder = true);

    try {
      final cancelled = await _cancelRepo.cancelOrder(
        orderId: order.id,
        userId: userId,
        token: token,
      );

      if (!mounted) return;
      setState(() => _isCancellingOrder = false);

      _showSnackBar(
        context,
        message: 'Order #${order.id} has been cancelled.',
        isError: false,
      );

      onSuccess?.call(cancelled);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancellingOrder = false);

      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      _showSnackBar(context, message: errorMsg, isError: true);
      onError?.call(errorMsg);
    }
  }

  void _showSnackBar(
      BuildContext context, {
        required String message,
        required bool isError,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. Cancel Order Dialog Widget
// ─────────────────────────────────────────────

/// Confirmation dialog for order cancellation.
///
/// Returns [true] if user confirms, [false] or null otherwise.
///
/// Usage:
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (_) => CancelOrderDialog(order: order),
/// );
/// if (confirmed == true) { /* proceed */ }
/// ```
class CancelOrderDialog extends StatelessWidget {
  final OrderModel order;

  const CancelOrderDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final total = order.totalAmount?.toStringAsFixed(2) ?? '0.00';
    final itemCount = order.items?.length ?? order.items ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cancel_outlined,
                size: 36,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Cancel Order?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              'Are you sure you want to cancel this order? This cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECFF)),
              ),
              child: Column(
                children: [
                  _DialogInfoRow(
                    icon: Icons.tag,
                    label: 'Order',
                    value: '#${order.id}',
                  ),
                  const SizedBox(height: 8),
                  _DialogInfoRow(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Items',
                    value: '$itemCount item${itemCount == 1 ? '' : 's'}',
                  ),
                  const SizedBox(height: 8),
                  _DialogInfoRow(
                    icon: Icons.attach_money,
                    label: 'Total',
                    value: '\$$total',
                    valueColor: const Color(0xFF1E88E5),
                    valueBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A1A2E),
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Keep Order',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Yes, Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

class _DialogInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;

  const _DialogInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// 3. Cancel Order Button Widget
// ─────────────────────────────────────────────

/// Drop-in cancel button that validates order status before showing dialog.
///
/// Only shows active state if order is PENDING; otherwise shows disabled/info.
///
/// Usage:
/// ```dart
/// CancelOrderButton(
///   order: order,
///   userId: userId,
///   token: token,
///   onCancelled: (cancelled) {
///     setState(() => _order = cancelled);
///   },
/// )
/// ```
class CancelOrderButton extends StatefulWidget {
  final OrderModel order;
  final int userId;
  final String token;
  final void Function(OrderModel cancelledOrder)? onCancelled;
  final void Function(String error)? onError;
  final bool fullWidth;

  const CancelOrderButton({
    super.key,
    required this.order,
    required this.userId,
    required this.token,
    this.onCancelled,
    this.onError,
    this.fullWidth = true,
  });

  @override
  State<CancelOrderButton> createState() => _CancelOrderButtonState();
}

class _CancelOrderButtonState extends State<CancelOrderButton> {
  final OrderRepository _repo = OrderRepository();
  bool _isCancelling = false;

  bool get _canCancel => widget.order.status == OrderStatus.pending;

  Future<void> _handleCancel() async {
    if (!_canCancel || _isCancelling) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CancelOrderDialog(order: widget.order),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);

    try {
      final cancelled = await _repo.cancelOrder(
        orderId: widget.order.id,
        userId: widget.userId,
        token: widget.token,
      );

      if (!mounted) return;
      setState(() => _isCancelling = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${widget.order.id} cancelled successfully.'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      widget.onCancelled?.call(cancelled);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCancelling = false);

      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel: $msg'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onError?.call(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canCancel) {
      // Show informational disabled state
      return Container(
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize:
          widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              widget.order.status == OrderStatus.cancelled
                  ? 'Order already cancelled'
                  : 'Cannot cancel — order is ${widget.order.status?.name ?? ""}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: widget.fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: _isCancelling ? null : _handleCancel,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[400],
          side: BorderSide(
            color: _isCancelling ? Colors.grey[300]! : Colors.red[300]!,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isCancelling
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Cancelling...',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Cancel Order',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 4. Static Utility Service
// ─────────────────────────────────────────────

/// Static utility for cancelling orders from controllers or providers,
/// where mixing into State is not possible.
///
/// Usage from a Provider/Riverpod controller:
/// ```dart
/// try {
///   final cancelled = await OrderCancellationService.cancel(
///     context: context,
///     order: order,
///     userId: userId,
///     token: token,
///   );
///   state = state.copyWith(order: cancelled);
/// } catch (e) {
///   state = state.copyWith(error: e.toString());
/// }
/// ```
class OrderCancellationService {
  static final OrderRepository _repo = OrderRepository();

  /// Shows confirmation dialog then cancels order via API.
  ///
  /// Throws [CancellationDeniedException] if user taps "Keep Order".
  /// Throws [Exception] if API call fails.
  /// Returns cancelled [OrderModel] on success.
  static Future<OrderModel> cancel({
    required BuildContext context,
    required OrderModel order,
    required int userId,
    required String token,
  }) async {
    // Validate status
    if (order.status != OrderStatus.pending) {
      throw Exception(
        'Cannot cancel order with status: ${order.status?.name}. Only PENDING orders can be cancelled.',
      );
    }

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CancelOrderDialog(order: order),
    );

    if (confirmed != true) {
      throw CancellationDeniedException('User cancelled the dialog.');
    }

    // API call
    return await _repo.cancelOrder(
      orderId: order.id,
      userId: userId,
      token: token,
    );
  }
}

/// Thrown when the user closes the cancellation dialog without confirming.
class CancellationDeniedException implements Exception {
  final String message;
  const CancellationDeniedException(this.message);

  @override
  String toString() => 'CancellationDeniedException: $message';
}