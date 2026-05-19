import 'order_item_model.dart';
import 'order_status_enum.dart';

/// OrderModel — unified, production-ready model.
///
/// Merges both versions of the model and covers all fields
/// returned by the API spec:
///   GET  /api/v1/orders/user/{userId}   (list)
///   GET  /api/v1/orders/{id}            (detail)
///   POST /api/v1/orders/user/{userId}/from-cart          (COD)
///   POST /api/v1/orders/user/{userId}/from-cart/bakong   (Bakong)
///   POST /api/v1/orders/{id}/user/{userId}/cancel
///   PATCH /api/v1/orders/{id}/status
class OrderModel {
  // ── Core identifiers ──────────────────────────────────────────
  final int id;

  /// Human-readable order number, e.g. "ORD-20260516-0042"
  final String? orderNumber;

  // ── Relations ─────────────────────────────────────────────────
  final int? userId;
  final int? addressId;

  // ── Status ────────────────────────────────────────────────────
  final OrderStatus? status;

  // ── Payment ───────────────────────────────────────────────────
  /// Raw payment method string: "COD" | "BAKONG"
  final String? paymentMethod;

  /// Nested payment object from API (may contain extra payment info)
  final Map<String, dynamic>? payment;

  /// Whether backend has verified the Bakong transaction
  final bool? paymentVerified;

  /// ISO-8601 timestamp of payment verification
  final String? verifiedAt;

  // ── Bakong-specific ───────────────────────────────────────────
  final String? bakongQr;
  final String? bakongMd5;

  // ── Financials ────────────────────────────────────────────────
  /// Primary total field (API v2 key: "total_amount")
  final double? totalAmount;

  /// Legacy / alternate total field (API v1 key: "total_price")
  final double? totalPrice;

  // ── Items ─────────────────────────────────────────────────────
  final List<OrderItemModel>? items;

  /// Lightweight item count returned on list endpoints (no full items)
  final int? itemsCount;

  // ── Address ───────────────────────────────────────────────────
  /// Full address object nested in the detail response
  final Map<String, dynamic>? address;

  // ── Timestamps ────────────────────────────────────────────────
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;

  /// Legacy string date field ("order_date") kept for backward compat
  final String? orderDate;

  const OrderModel({
    required this.id,
    this.orderNumber,
    this.userId,
    this.addressId,
    this.status,
    this.paymentMethod,
    this.payment,
    this.paymentVerified,
    this.verifiedAt,
    this.bakongQr,
    this.bakongMd5,
    this.totalAmount,
    this.totalPrice,
    this.items,
    this.itemsCount,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.orderDate,
  });

  // ── Convenience getters ───────────────────────────────────────

  /// Returns the best available total (prefers totalAmount, falls back to totalPrice)
  double get total => totalAmount ?? totalPrice ?? 0.0;

  /// Resolved payment method string (checks both flat and nested payment object)
  String get resolvedPaymentMethod =>
      paymentMethod?.isNotEmpty == true
          ? paymentMethod!
          : (payment?['payment_method'] as String? ?? '');

  /// True when the Bakong payment has been verified by the backend
  bool get isBakongVerified => paymentVerified == true;

  /// Number of items — uses itemsCount from list response, falls back to items length
  int get resolvedItemsCount => itemsCount ?? items?.length ?? 0;

  // ── Deserialization ───────────────────────────────────────────

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return OrderModel(
      // Core
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number'] as String?,

      // Relations
      userId: (json['user_id'] ?? json['userId'] as num?)?.toInt(),
      addressId: (json['address_id'] ?? json['addressId'] as num?)?.toInt(),

      // Status
      status: OrderStatusExtension.fromString(
        json['status'] as String?,
      ),

      // Payment (flat field takes precedence over nested payment object)
      paymentMethod: json['payment_method'] as String? ??
          (json['payment'] as Map<String, dynamic>?)?['payment_method']
          as String?,
      payment: json['payment'] as Map<String, dynamic>?,
      paymentVerified: json['payment_verified'] as bool?,
      verifiedAt: json['verified_at'] as String?,

      // Bakong
      bakongQr: json['bakong_qr'] as String?,
      bakongMd5: json['bakong_md5'] as String?,

      // Financials — handle num → double safely
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),

      // Items
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemsCount: (json['items_count'] as num?)?.toInt(),

      // Address
      address: json['address'] as Map<String, dynamic>?,

      // Timestamps
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      cancelledAt: _parseDate(json['cancelled_at']),
      orderDate: json['order_date'] as String?,
    );
  }

  // ── Serialization ─────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (orderNumber != null) 'order_number': orderNumber,
      if (userId != null) 'user_id': userId,
      if (addressId != null) 'address_id': addressId,
      if (status != null) 'status': status!.value,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (payment != null) 'payment': payment,
      if (paymentVerified != null) 'payment_verified': paymentVerified,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (bakongQr != null) 'bakong_qr': bakongQr,
      if (bakongMd5 != null) 'bakong_md5': bakongMd5,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (totalPrice != null) 'total_price': totalPrice,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (itemsCount != null) 'items_count': itemsCount,
      if (address != null) 'address': address,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      if (orderDate != null) 'order_date': orderDate,
    };
  }

  // ── copyWith ──────────────────────────────────────────────────

  OrderModel copyWith({
    int? id,
    String? orderNumber,
    int? userId,
    int? addressId,
    OrderStatus? status,
    String? paymentMethod,
    Map<String, dynamic>? payment,
    bool? paymentVerified,
    String? verifiedAt,
    String? bakongQr,
    String? bakongMd5,
    double? totalAmount,
    double? totalPrice,
    List<OrderItemModel>? items,
    int? itemsCount,
    Map<String, dynamic>? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    String? orderDate,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      addressId: addressId ?? this.addressId,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      payment: payment ?? this.payment,
      paymentVerified: paymentVerified ?? this.paymentVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      bakongQr: bakongQr ?? this.bakongQr,
      bakongMd5: bakongMd5 ?? this.bakongMd5,
      totalAmount: totalAmount ?? this.totalAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      items: items ?? this.items,
      itemsCount: itemsCount ?? this.itemsCount,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      orderDate: orderDate ?? this.orderDate,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  String toString() =>
      'OrderModel(id: $id, orderNumber: $orderNumber, status: ${status?.name}, '
          'total: $total, items: ${resolvedItemsCount}, paymentMethod: $resolvedPaymentMethod)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
