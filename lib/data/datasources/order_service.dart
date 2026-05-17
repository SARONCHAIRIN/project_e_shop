import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// OrderService handles all order-related API calls (create, retrieve, cancel, etc.)
class OrderService {
  final Dio _dio;
  static const String _baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  OrderService({Dio? dio}) : _dio = dio ?? Dio();

  /// Create an order with Cash on Delivery (COD) payment
  /// 
  /// POST /api/v1/orders/user/{userId}/from-cart
  /// Body: { address_id, payment_method: "COD" }
  /// Returns: { id, user_id, address_id, payment_method, status, total_price, created_at }
  Future<Map<String, dynamic>> createCODOrder({
    required int userId,
    required int addressId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/orders/user/$userId/from-cart',
        data: {
          'address_id': addressId,
          'payment_method': 'COD',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[OrderService] createCODOrder success: Order #${data['id']}');
        return data;
      }
      throw Exception('Failed to create COD order: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[OrderService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[OrderService] Error: $e');
      rethrow;
    }
  }

  /// Create an order with Bakong QR payment
  /// 
  /// POST /api/v1/orders/user/{userId}/from-cart/bakong
  /// Body: { address_id, payment_method: "BAKONG" }
  /// Returns: { id, user_id, address_id, payment_method, status, total_price, bakong_qr, bakong_md5, created_at }
  Future<Map<String, dynamic>> createBakongOrder({
    required int userId,
    required int addressId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/orders/user/$userId/from-cart/bakong',
        data: {
          'address_id': addressId,
          'payment_method': 'BAKONG',
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[OrderService] createBakongOrder success: Order #${data['id']}');
        return data;
      }
      throw Exception('Failed to create Bakong order: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[OrderService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[OrderService] Error: $e');
      rethrow;
    }
  }

  /// Get all orders for a user with pagination
  /// 
  /// GET /api/v1/orders/user/{userId}?page={page}&limit={limit}
  /// Returns: { data: [...], pagination: { page, limit, total } }
  Future<Map<String, dynamic>> getOrders({
    required int userId,
    required String token,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/orders/user/$userId',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('[OrderService] getOrders success: ${data['data']?.length ?? 0} orders');
        return data;
      }
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[OrderService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[OrderService] Error: $e');
      rethrow;
    }
  }

  /// Get detailed information about a specific order
  /// 
  /// GET /api/v1/orders/{id}
  /// Returns: { id, status, payment_method, total_price, address, items, created_at }
  Future<Map<String, dynamic>> getOrderDetail({
    required int orderId,
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/orders/$orderId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[OrderService] getOrderDetail success: Order #${data['id']}');
        return data;
      }
      throw Exception('Failed to fetch order detail: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[OrderService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[OrderService] Error: $e');
      rethrow;
    }
  }

  /// Cancel an order (only if status is PENDING)
  /// 
  /// POST /api/v1/orders/{id}/user/{userId}/cancel
  /// Returns: { id, status, cancelled_at }
  Future<Map<String, dynamic>> cancelOrder({
    required int orderId,
    required int userId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/orders/$orderId/user/$userId/cancel',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[OrderService] cancelOrder success: Order #${data['id']} cancelled');
        return data;
      }
      throw Exception('Failed to cancel order: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[OrderService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[OrderService] Error: $e');
      rethrow;
    }
  }

  /// Update the status of an order (admin/system use)
  /// 
  /// PATCH /api/v1/orders/{id}/status?status={status}
  /// Returns: { id, status, updated_at }
  Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
    required String token,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/orders/$orderId/status',
        queryParameters: {'status': status},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint('[OrderService] updateOrderStatus success: Order #${data['id']} → $status');
        return data;
      }
      throw Exception('Failed to update order status: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('[OrderService] DioException: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('[OrderService] Error: $e');
      rethrow;
    }
  }

  /// Helper to handle Dio exceptions
  Exception _handleError(DioException e) {
    String message = 'Network error';
    
    if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      message = 'Response timeout';
    } else if (e.response != null) {
      message = 'Error ${e.response?.statusCode}: ${e.response?.statusMessage}';
    }
    
    return Exception(message);
  }
}

