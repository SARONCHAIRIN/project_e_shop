/*
import 'order_item_model.dart';
import 'order_status_enum.dart';

/// OrderModel represents an order returned by the API
class OrderModel {
  final int id;
  final int userId;
  final int addressId;
  final String paymentMethod;
  final OrderStatus status;
  final double totalPrice;
  final List<OrderItemModel> items;
  final String? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.addressId,
    required this.paymentMethod,
    required this.status,
    required this.totalPrice,
    required this.items,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? 0,
      addressId: json['address_id'] ?? json['addressId'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      status: OrderStatusExtension.fromString(json['status'] as String?),
      totalPrice: (json['total_price'] ?? json['totalAmount'] ?? 0).toDouble(),
      items: itemsJson.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'payment_method': paymentMethod,
      'status': status.value,
      'total_price': totalPrice,
      'items': items.map((i) => i.toJson()).toList(),
      'created_at': createdAt,
    };
  }
}
*/



import 'order_item_model.dart';
import 'order_status_enum.dart';

class OrderModel {
  final int id;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final String paymentMethod;
  final String orderNumber;
  final double totalAmount;
  final String? orderDate;

  OrderModel({
    required this.id,
    required this.status,
    required this.items,
    required this.paymentMethod,
    required this.orderNumber,
    required this.totalAmount,
    this.orderDate,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: json['id'] ?? 0,
      status: OrderStatusExtension.fromString(json['status']),
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),
      paymentMethod:
      json['payment']?['payment_method'] ?? '',
      orderNumber: json['order_number'] ?? '',
      totalAmount:
      (json['total_amount'] ?? 0).toDouble(),
      orderDate: json['order_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.value,
      'items': items.map((e) => e.toJson()).toList(),
      'payment_method': paymentMethod,
      'order_number': orderNumber,
      'total_amount': totalAmount,
      'order_date': orderDate,
    };
  }
}