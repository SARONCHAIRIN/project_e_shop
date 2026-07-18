class ReturnRequestModel {
  final String reason;
  final double amount;
  final int orderId;
  final int customerId;
  final int productId;
  final String returnType;

  ReturnRequestModel({
    required this.reason,
    required this.amount,
    required this.orderId,
    required this.customerId,
    required this.productId,
    required this.returnType,
  });

  Map<String, dynamic> toJson() {
    return {
      "reason": reason,
      "amount": amount,
      "order_id": orderId,
      "customer_id": customerId,
      "product_id": productId,
      "return_type": returnType,
    };
  }
}