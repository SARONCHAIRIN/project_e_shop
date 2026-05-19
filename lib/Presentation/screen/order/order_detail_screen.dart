import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/datasources/adress/adress_service.dart';
import '../../../data/models/address/address_model.dart';
import '../../../data/models/order/order_item_model.dart';
import '../../../data/models/order/order_model.dart';
import '../../../data/models/order/order_status_enum.dart';
import '../../../data/repositories/address/address_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../widgets/order/order_status_timeline.dart';
import '../../widgets/order/order_item_card.dart';
import '../../widgets/payment/payment_status_badge.dart';

/// TASK 12: Order Detail Screen
///
/// Features:
/// - Full order information display
/// - Status progression timeline
/// - Product list with images & totals
/// - Delivery address card
/// - Payment method & details
/// - Cancel order (only if PENDING)
/// - Track shipment (SHIPPED/DELIVERED)
class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final int userId;
  final String token;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.userId,
    required this.token,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _orderRepository = OrderRepository();
  final AddressRepository _addressRepository =
  AddressRepository(AddressService());

  AddressModel? _address;

  OrderModel? _order;
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
    _loadOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await _orderRepository.getOrderDetail(
        orderId: widget.orderId,
        token: widget.token,
      );
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order details.';
        _isLoading = false;
      });
    }
  }

  bool get _canCancel => _order?.status == OrderStatus.pending;
  bool get _canTrack =>
      _order?.status == OrderStatus.shipped ||
          _order?.status == OrderStatus.delivered;

  String get _formattedDate {
    // Prefer parsed createdAt DateTime, fall back to raw orderDate string
    final date = _order?.createdAt;
    if (date != null) {
      return '${date.day} ${_monthName(date.month)} ${date.year}';
    }
    final raw = _order?.orderDate;
    if (raw != null && raw.isNotEmpty) return raw;
    return '—';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red[400], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. Your order will be cancelled immediately.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Order #${widget.orderId} — \$${_order?.total.toStringAsFixed(2) ?? "0.00"}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Order',
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cancel Order',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder() async {
    if (_isCancelling) return;

    setState(() => _isCancelling = true);

    try {
      await _orderRepository.cancelOrder(
        orderId: widget.orderId,
        userId: widget.userId,
        token: widget.token,
      );

      setState(() {
        _order = _order?.copyWith(
          status: OrderStatus.cancelled,
          cancelledAt: DateTime.now(),
        );
        _isCancelling = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order cancelled successfully.'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isCancelling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _trackShipment() {
    // Placeholder for tracking integration
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.local_shipping_outlined,
                size: 48, color: Color(0xFF1E88E5)),
            const SizedBox(height: 12),
            const Text(
              'Shipment Tracking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Tracking ID: #${widget.orderId.toString().padLeft(8, '0')}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderRepository.getOrderDetail(
        orderId: widget.orderId,
        token: widget.token,
      );

      _order = order;

      // LOAD ADDRESS
      if (order.addressId != null) {
        try {
          final address = await _addressRepository.getAddressById(
            userId: widget.userId,
            token: widget.token,
          );

          _address = address;
        } catch (e) {
          debugPrint('Failed to load address: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ─── BUILD SECTIONS ────────────────────────────────────────

  Widget _buildStatusHeader() {
    final status = _order!.status;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _order!.orderNumber != null
                        ? _order!.orderNumber!
                        : 'Order #${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on $_formattedDate',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
              OrderStatusBadge(
                status: status?.name.toUpperCase() ?? 'PENDING',
                isLarge: false,
              ),
            ],
          ),
          const SizedBox(height: 20),
          OrderStatusTimeline(
            currentStatus: status?.name.toUpperCase() ?? 'PENDING',
            statusTimestamps: {
              if (_order!.createdAt != null) 'PENDING': _order!.createdAt!,
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    final List<OrderItemModel> items = _order?.items ?? [];

    return _SectionCard(
      title: 'Items (${items.length})',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final sku = item.productSku;

          final isLast = entry.key == items.length - 1;

          return Column(
            children: [
              OrderItemCard(
                productId: sku.id,
                productName: sku.description,
                price: item.unitPrice,
                quantity: item.quantity,

                /// your API currently has no image
                imageUrl: null,
              ),

              if (!isLast)
                Divider(
                  color: Colors.grey[200],
                  height: 20,
                  thickness: 1,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddressSection() {
    if (_address == null) {
      return _SectionCard(
        title: 'Delivery Address',
        icon: Icons.location_on_outlined,
        child: const Text(
          'No address found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _SectionCard(
      title: 'Delivery Address',
      icon: Icons.location_on_outlined,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8ECFF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home_outlined,
                size: 20,
                color: Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _address!.addressline1,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_address!.city}, ${_address!.zipcode}, ${_address!.country}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
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
  Widget _buildPaymentSection() {
    final method = _order!.resolvedPaymentMethod.toUpperCase();
    final total = _order!.total;
    final isVerified = _order!.isBakongVerified;
    final isBakong = method == 'BAKONG';
    final cancelledAt = _order!.cancelledAt;

    return _SectionCard(
      title: 'Payment Details',
      icon: Icons.payment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Method row with verified badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Row(
                children: [
                  Text(
                    isBakong ? 'Bakong QR' : 'Cash on Delivery',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  if (isBakong && isVerified) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 11, color: Colors.green[600]),
                          const SizedBox(width: 3),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DetailRow(
            label: 'Order Date',
            value: _formattedDate,
          ),
          // Show cancelled date if order was cancelled
          if (cancelledAt != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Cancelled On',
              value: '${cancelledAt.day} ${_monthName(cancelledAt.month)} ${cancelledAt.year}',
              valueColor: Colors.red[400],
            ),
          ],
          // Show verification date for Bakong
          if (isBakong && _order!.verifiedAt != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Verified At',
              value: _order!.verifiedAt!,
              valueColor: Colors.green[600],
            ),
          ],
          const SizedBox(height: 10),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: [
          if (_canTrack)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _trackShipment,
                icon: const Icon(Icons.local_shipping_outlined, size: 20),
                label: const Text(
                  'Track Shipment',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          if (_canTrack) const SizedBox(height: 10),
          if (_canCancel)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isCancelling ? null : _showCancelDialog,
                icon: _isCancelling
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red,
                  ),
                )
                    : const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  _isCancelling ? 'Cancelling...' : 'Cancel Order',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.red[300]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          if (!_canCancel && !_canTrack)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Text(
                    _order?.status == OrderStatus.cancelled
                        ? 'This order has been cancelled.'
                        : 'No actions available.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1E88E5)),
          SizedBox(height: 16),
          Text('Loading order details...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red[300]),
            const SizedBox(height: 16),
            const Text(
              'Failed to load order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchOrderDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          _order?.orderNumber ?? 'Order #${widget.orderId}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A2E)),
            onPressed: _fetchOrderDetail,
          ),
        ],
      ),


      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
          ? _buildErrorState()
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if ((_order!.items ?? []).isNotEmpty)
                    _buildItemsSection(),
                  const SizedBox(height: 12),
                  _buildAddressSection(),
                  const SizedBox(height: 12),
                  _buildPaymentSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1E88E5)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }


}