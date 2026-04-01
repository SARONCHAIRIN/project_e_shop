class OrderModel {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String status;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}