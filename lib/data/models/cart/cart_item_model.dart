class CartItem {
  final int id;
  final String name;
  final int quantity;
  final int totalPrice;
  final String image;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.totalPrice,
    required this.image,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] != null
          ? (json['id'] is double ? (json['id'] as double).toInt() : json['id'])
          : 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] != null
          ? (json['quantity'] is double ? (json['quantity'] as double).toInt() : json['quantity'])
          : 0,
      totalPrice: json['total_price'] != null
          ? (json['total_price'] is double
          ? (json['total_price'] as double).toInt()
          : json['total_price'])
          : 0,
      image: json['image'] ?? '',
    );
  }
}