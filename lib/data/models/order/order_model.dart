import 'order_item_model.dart';
import 'order_status_enum.dart';

class OrderModel {
  final int id;
  final String? orderNumber;
  final int? userId;
  final int? addressId;
  final OrderStatus? status;

  final String? paymentMethod;
  final Map<String, dynamic>? payment;
  final bool? paymentVerified;
  final String? verifiedAt;

  // ── Bakong-specific ───────────────────────────────────────────
  final String? qrCode;       //  NEW: from root "qr_code"
  final String? bakongQr;     // legacy fallback
  final String? bakongMd5;
  final String? paymentUrl;

  final double? totalAmount;
  final double? totalPrice;

  final List<OrderItemModel>? items;
  final int? itemsCount;

  final Map<String, dynamic>? address;
  final Map<String, dynamic>? shippingAddress; // NEW: matches "shipping_address"

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;
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
    this.qrCode,
    this.bakongQr,
    this.bakongMd5,
    this.paymentUrl,
    this.totalAmount,
    this.totalPrice,
    this.items,
    this.itemsCount,
    this.address,
    this.shippingAddress,
    this.createdAt,
    this.updatedAt,
    this.cancelledAt,
    this.orderDate,
  });

  double get total => totalAmount ?? totalPrice ?? 0.0;

  String get resolvedPaymentMethod =>
      paymentMethod?.isNotEmpty == true
          ? paymentMethod!
          : (payment?['payment_method'] as String? ?? '');

  bool get isBakongVerified => paymentVerified == true;

  int get resolvedItemsCount => itemsCount ?? items?.length ?? 0;

  /// Resolved QR string — prefers root "qr_code", falls back to legacy "bakong_qr"
  String get resolvedQrCode => qrCode ?? bakongQr ?? '';

  ///  Payment reference code from nested payment object (e.g. "PAY-PC4059M7")
  String? get paymentCode => payment?['code'] as String?;

  ///  Bakong transaction id from nested payment object
  String? get transactionId => payment?['transaction_id'] as String?;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number'] as String?,

      userId: (json['user_id'] ?? json['userId'] as num?)?.toInt(),
      addressId: (json['address_id'] ?? json['addressId'] as num?)?.toInt(),

      status: OrderStatusExtension.fromString(json['status'] as String?),

      paymentMethod: json['payment_method'] as String? ??
          (json['payment'] as Map<String, dynamic>?)?['payment_method']
          as String?,
      payment: json['payment'] as Map<String, dynamic>?,
      paymentVerified: json['payment_verified'] as bool?,
      verifiedAt: json['verified_at'] as String?,

      qrCode: json['qr_code'] as String?,
      bakongQr: json['bakong_qr'] as String?,
      bakongMd5: json['bakong_md5'] as String?,
      paymentUrl: json['payment_url'] as String?,

      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),

      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemsCount: (json['items_count'] as num?)?.toInt(),

      address: json['address'] as Map<String, dynamic>?,
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?, // ✅ NEW

      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      cancelledAt: _parseDate(json['cancelled_at']),
      orderDate: json['order_date'] as String?,
    );
  }

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
      if (qrCode != null) 'qr_code': qrCode,
      if (bakongQr != null) 'bakong_qr': bakongQr,
      if (bakongMd5 != null) 'bakong_md5': bakongMd5,
      if (paymentUrl != null) 'payment_url': paymentUrl,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (totalPrice != null) 'total_price': totalPrice,
      if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
      if (itemsCount != null) 'items_count': itemsCount,
      if (address != null) 'address': address,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      if (orderDate != null) 'order_date': orderDate,
    };
  }

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
    String? qrCode,
    String? bakongQr,
    String? bakongMd5,
    String? paymentUrl,
    double? totalAmount,
    double? totalPrice,
    List<OrderItemModel>? items,
    int? itemsCount,
    Map<String, dynamic>? address,
    Map<String, dynamic>? shippingAddress,
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
      qrCode: qrCode ?? this.qrCode,
      bakongQr: bakongQr ?? this.bakongQr,
      bakongMd5: bakongMd5 ?? this.bakongMd5,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      totalAmount: totalAmount ?? this.totalAmount,
      totalPrice: totalPrice ?? this.totalPrice,
      items: items ?? this.items,
      itemsCount: itemsCount ?? this.itemsCount,
      address: address ?? this.address,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      orderDate: orderDate ?? this.orderDate,
    );
  }

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
          'total: $total, items: $resolvedItemsCount, paymentMethod: $resolvedPaymentMethod, '
          'qrCode: ${resolvedQrCode.isNotEmpty ? "present" : "none"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrderModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}