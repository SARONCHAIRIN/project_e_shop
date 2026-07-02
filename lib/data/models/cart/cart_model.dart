// import 'cart_item_model.dart';
//
// class CartModel {
//   final int id;
//   final double totalPrice;
//   final int totalItems;
//   final List<CartItem> items;
//
//   CartModel({
//     required this.id,
//     required this.totalPrice,
//     required this.totalItems,
//     required this.items,
//   });
//
//   factory CartModel.fromJson(Map<String, dynamic> json) {
//     return CartModel(
//       id: json['id'] != null
//           ? (json['id'] is double ? (json['id'] as double).toInt() : json['id'])
//           : 0,
//       totalPrice: json['total_price'] != null
//           ? (json['total_price'] is num
//                 ? (json['total_price'] as num).toDouble()
//                 : double.tryParse(json['total_price'].toString()) ?? 0.0)
//           : 0.0,
//       totalItems: json['total_items'] != null
//           ? (json['total_items'] is double
//                 ? (json['total_items'] as double).toInt()
//                 : json['total_items'])
//           : 0,
//       items:
//           (json['items'] as List<dynamic>?)
//               ?.map((e) => CartItem.fromJson(e))
//               .toList() ??
//           [],
//     );
//   }
// }
import 'cart_item_model.dart';

class CartModel {
  final int id;
  final double totalPrice;
  final int totalItems;
  final List<CartItem> items;

  CartModel({
    required this.id,
    required this.totalPrice,
    required this.totalItems,
    required this.items,
  });

  CartModel copyWith({
    int? id,
    double? totalPrice,
    int? totalItems,
    List<CartItem>? items,
  }) {
    return CartModel(
      id: id ?? this.id,
      totalPrice: totalPrice ?? this.totalPrice,
      totalItems: totalItems ?? this.totalItems,
      items: items ?? this.items,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] ?? 0,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      totalItems: json['total_items'] ?? 0,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}