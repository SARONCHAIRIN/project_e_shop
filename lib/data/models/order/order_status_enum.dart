// Order status enum with helper conversion methods
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
	switch (this) {
	  case OrderStatus.pending:
		return 'PENDING';
	  case OrderStatus.processing:
		return 'PROCESSING';
	  case OrderStatus.shipped:
		return 'SHIPPED';
	  case OrderStatus.delivered:
		return 'DELIVERED';
	  case OrderStatus.cancelled:
		return 'CANCELLED';
	}
  }

  static OrderStatus fromString(String? status) {
	if (status == null) return OrderStatus.pending;
	switch (status.toUpperCase()) {
	  case 'PROCESSING':
		return OrderStatus.processing;
	  case 'SHIPPED':
		return OrderStatus.shipped;
	  case 'DELIVERED':
		return OrderStatus.delivered;
	  case 'CANCELLED':
		return OrderStatus.cancelled;
	  case 'PENDING':
	  default:
		return OrderStatus.pending;
	}
  }
}


