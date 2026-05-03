import 'package:e_shop/data/models/product_model_eshop.dart';

class CartItem {
  final int id;
  final ProductSku productSku;
  final String name;
  int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.productSku,
    required this.name,
    required this.quantity,
    required this.image,
  });
  // Auto-calculated from quantity × unit price
  double get totalPrice => (productSku.price * quantity).toDouble();

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] != null
          ? (json['id'] is double ? (json['id'] as double).toInt() : json['id'])
          : 0,
      productSku: ProductSku.fromJson(json['productSku']),
      name: json['name'] ?? '',
      quantity: json['quantity'] != null
          ? (json['quantity'] is double ? (json['quantity'] as double).toInt() : json['quantity'])
          :0,
      image: json['image'] ?? '',
    );
  }
}