import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// OrderService handles all order-related API calls (create, retrieve, cancel, etc.)
class OrderService {
  final Dio _dio;

  static const String _baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';
  static const String _baseUrllocal = 'http://localhost:8080/api/v1';

  // angkor home wifi
  static const String _baseUrllocalwifi = 'http://192.168.18.61:8080/api/v1';

  // OrderService({Dio? dio}) : _dio = dio ?? Dio();
  OrderService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 120),
              sendTimeout: const Duration(seconds: 60),
            ),
          );

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
        // '$_baseUrllocal/orders/user/from-cart',
        '$_baseUrllocalwifi/orders/user/from-cart',
        queryParameters: {'userId': userId},
        data: {'address_id': addressId, 'payment_method': 'COD'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint(
          '[OrderService] createCODOrder success: Order #${data['id']}',
        );
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
      debugPrint('================ START BAKONG API ================');
      debugPrint(' STEP 1: Prepare request');
      debugPrint('User ID: $userId');
      debugPrint('Address ID: $addressId');

      final url = '$_baseUrllocalwifi/orders/user/from-cart/bakong';
      // final url = '$_baseUrllocal/orders/user/from-cart/bakong';
      debugPrint(' STEP 2: URL => $url');

      final body = {'address_id': addressId, 'payment_method': 'BAKONG'};
      debugPrint(' STEP 3: BODY => $body');

      debugPrint(' STEP 4: Sending request...');

      final response = await _dio.post(
        url,
        queryParameters: {'userId': userId},
        data: body,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      debugPrint(' STEP 5: Response received');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data: ${response.data}');

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;

        debugPrint('================ SUCCESS BAKONG =================');
        debugPrint('Order ID: ${data['id']}');
        debugPrint('=================================================');

        return data;
      }

      throw Exception('Failed: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('================ DIO ERROR =================');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('===========================================');

      throw Exception('Response timeout');
    } catch (e) {
      debugPrint('================ UNKNOWN ERROR =================');
      debugPrint(e.toString());
      rethrow;
    }
  }

  /// Get all orders for a user with pagination
  ///
  /// GET /api/v1/orders/user/{userId}?page={page}&limit={limit}
  /// Returns: { data: [...], pagination: { page, limit, total } }
  ///
  Future<Map<String, dynamic>> getOrders({
    required int userId,
    required String token,
    int page = 0,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '$_baseUrllocalwifi/orders?page=0&size=100&sort=DESC',
      // '$_baseUrllocalwifi/orders?page=0&size=100&sort=DESC',
      // 'https://e-shop-1-m034.onrender.com/api/v1/orders/user/id/?userId=4&page=0&size=10&sort=DESC',
      queryParameters: {'userId': userId, 'page': page, 'size': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint("ORDER URL => $_baseUrl/orders");

    if (response.statusCode == 200) {
      return response.data; // pageable format
    }

    throw Exception("Failed to fetch orders");
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

        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint(
          '[OrderService] getOrderDetail success: Order #${data['id']}',
        );
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
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint(
          '[OrderService] cancelOrder success: Order #${data['id']} cancelled',
        );
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
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        debugPrint(
          '[OrderService] updateOrderStatus success: Order #${data['id']} → $status',
        );
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
