import '../product_model_eshop.dart';

class CartItem {
  final int id;
  final ProductSku productSku;
  final String name;
  int quantity;
  final List<String> mainImage;

  CartItem({
    required this.id,
    required this.productSku,
    required this.name,
    required this.quantity,
    required this.mainImage,
  });

  double get totalPrice => (productSku.price * quantity).toDouble();

  CartItem copyWith({
    int? id,
    ProductSku? productSku,
    String? name,
    int? quantity,
    List<String>? mainImage,
  }) {
    return CartItem(
      id: id ?? this.id,
      productSku: productSku ?? this.productSku,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      mainImage: mainImage ?? this.mainImage,
    );
  }

  static List<String> extractImages(String raw) {
    final regex = RegExp(r'https?://[^,\]\s]+');
    return regex.allMatches(raw).map((e) => e.group(0)!).toList();
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final sku = json['productSku'];

    return CartItem(
      id: json['id'] ?? 0,
      productSku: ProductSku.fromJson(sku),

      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,

      mainImage:
          (sku?['main_image'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
