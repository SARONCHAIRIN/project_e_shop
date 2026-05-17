import 'package:flutter/foundation.dart';
import '../datasources/order_service.dart';
import '../models/order/order_model.dart';
import '../models/order/order_status_enum.dart';

/// OrderRepository handles order-related business logic and wraps OrderService
class OrderRepository {
  final OrderService _orderService;

  OrderRepository({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  /// Create an order with Cash on Delivery (COD) payment
  /// 
  /// Wraps: OrderService.createCODOrder()
  /// Handles: Error logging, response parsing, validation
  /// Returns: OrderModel with order details
  Future<OrderModel> createCODOrder({
    required int userId,
    required int addressId,
    required String token,
  }) async {
    try {
      debugPrint('[OrderRepository] createCODOrder for user $userId');
      final data = await _orderService.createCODOrder(
        userId: userId,
        addressId: addressId,
        token: token,
      );
      final order = OrderModel.fromJson(data);
      debugPrint('[OrderRepository] COD Order created: #${order.id}');
      return order;
    } catch (e) {
      debugPrint('[OrderRepository] Error creating COD order: $e');
      rethrow;
    }
  }

  /// Create an order with Bakong QR payment
  /// 
  /// Wraps: OrderService.createBakongOrder()
  /// Handles: Error logging, response parsing, validation
  /// Returns: OrderModel with QR data (bakong_qr, bakong_md5)
  Future<OrderModel> createBakongOrder({
    required int userId,
    required int addressId,
    required String token,
  }) async {
    try {
      debugPrint('[OrderRepository] createBakongOrder for user $userId');
      final data = await _orderService.createBakongOrder(
        userId: userId,
        addressId: addressId,
        token: token,
      );
      final order = OrderModel.fromJson(data);
      debugPrint('[OrderRepository] Bakong Order created: #${order.id}');
      return order;
    } catch (e) {
      debugPrint('[OrderRepository] Error creating Bakong order: $e');
      rethrow;
    }
  }

  /// Get paginated list of orders for a user
  /// 
  /// Wraps: OrderService.getOrders()
  /// Handles: Error logging, pagination parsing, response validation
  /// Returns: List<OrderModel> and pagination info
  Future<({List<OrderModel> orders, Map<String, dynamic> pagination})> getOrders({
    required int userId,
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('[OrderRepository] getOrders page=$page, limit=$limit');
      final data = await _orderService.getOrders(
        userId: userId,
        token: token,
        page: page,
        limit: limit,
      );

      final ordersList = (data['data'] as List<dynamic>? ?? [])
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

      debugPrint('[OrderRepository] Fetched ${ordersList.length} orders');
      return (orders: ordersList, pagination: pagination);
    } catch (e) {
      debugPrint('[OrderRepository] Error fetching orders: $e');
      rethrow;
    }
  }

  /// Get detailed information about a specific order
  /// 
  /// Wraps: OrderService.getOrderDetail()
  /// Handles: Error logging, response parsing, nested object creation
  /// Returns: OrderModel with full details (items, address, payment info)
  Future<OrderModel> getOrderDetail({
    required int orderId,
    required String token,
  }) async {
    try {
      debugPrint('[OrderRepository] getOrderDetail for order $orderId');
      final data = await _orderService.getOrderDetail(
        orderId: orderId,
        token: token,
      );
      final order = OrderModel.fromJson(data);
      debugPrint('[OrderRepository] Order detail fetched: #${order.id} (${order.items.length} items)');
      return order;
    } catch (e) {
      debugPrint('[OrderRepository] Error fetching order detail: $e');
      rethrow;
    }
  }

  /// Cancel an order (only if status is PENDING)
  /// 
  /// Wraps: OrderService.cancelOrder()
  /// Handles: Error logging, status validation, response parsing
  /// Precondition: Order status must be PENDING
  /// Returns: Cancelled OrderModel
  Future<OrderModel> cancelOrder({
    required int orderId,
    required int userId,
    required String token,
  }) async {
    try {
      debugPrint('[OrderRepository] Attempting to cancel order $orderId');
      
      // Fetch current order to check status
      final order = await getOrderDetail(orderId: orderId, token: token);
      
      // Only allow cancellation of PENDING orders
      if (order.status != OrderStatus.pending) {
        throw Exception('Cannot cancel order with status: ${order.status.value}');
      }
      
      final data = await _orderService.cancelOrder(
        orderId: orderId,
        userId: userId,
        token: token,
      );
      
      final cancelledOrder = OrderModel.fromJson(data);
      debugPrint('[OrderRepository] Order #$orderId cancelled successfully');
      return cancelledOrder;
    } catch (e) {
      debugPrint('[OrderRepository] Error cancelling order: $e');
      rethrow;
    }
  }

  /// Update the status of an order (admin/system use)
  /// 
  /// Wraps: OrderService.updateOrderStatus()
  /// Handles: Error logging, status validation, response parsing
  /// Valid statuses: PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
  /// Returns: Updated OrderModel
  Future<OrderModel> updateOrderStatus({
    required int orderId,
    required String status,
    required String token,
  }) async {
    try {
      // Validate status enum
      final validStatuses = ['PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'];
      if (!validStatuses.contains(status.toUpperCase())) {
        throw Exception('Invalid status: $status. Must be one of: $validStatuses');
      }

      debugPrint('[OrderRepository] updateOrderStatus #$orderId → $status');
      final data = await _orderService.updateOrderStatus(
        orderId: orderId,
        status: status,
        token: token,
      );
      
      final updatedOrder = OrderModel.fromJson(data);
      debugPrint('[OrderRepository] Order #$orderId status updated to $status');
      return updatedOrder;
    } catch (e) {
      debugPrint('[OrderRepository] Error updating order status: $e');
      rethrow;
    }
  }

  /// Load all orders for a user with automatic pagination
  /// 
  /// Retrieves all pages of orders sequentially
  /// Handles pagination internally
  /// Returns: Complete list of all user orders
  Future<List<OrderModel>> loadAllOrders({
    required int userId,
    required String token,
  }) async {
    try {
      debugPrint('[OrderRepository] loadAllOrders for user $userId');
      final allOrders = <OrderModel>[];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final result = await getOrders(
          userId: userId,
          token: token,
          page: page,
          limit: 10,
        );

        allOrders.addAll(result.orders);

        final pagination = result.pagination;
        final currentPage = pagination['page'] as int? ?? 1;
        final limit = pagination['limit'] as int? ?? 10;
        final total = pagination['total'] as int? ?? 0;

        hasMore = (currentPage * limit) < total;
        page++;

        debugPrint('[OrderRepository] Loaded page $currentPage (${allOrders.length}/$total orders)');
      }

      debugPrint('[OrderRepository] loadAllOrders complete: ${allOrders.length} total orders');
      return allOrders;
    } catch (e) {
      debugPrint('[OrderRepository] Error loading all orders: $e');
      rethrow;
    }
  }
}



