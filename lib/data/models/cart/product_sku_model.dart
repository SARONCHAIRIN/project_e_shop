class ProductSKU {
  final int id;
  final String sku;
  final String description;
  final int price;
  final String color;
  final String size;
  final int quantity;

  ProductSKU({
    required this.id,
    required this.sku,
    required this.description,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory ProductSKU.fromJson(Map<String, dynamic> json) {
    return ProductSKU(
      id: (json['id'] ?? 0) is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,

      sku: json['sku'] ?? '',

      description: json['description'] ?? '',

      price: (json['price'] ?? 0) is num
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,

      color: json['color'] ?? '',
      size: json['size'] ?? '',

      quantity: (json['quantity'] ?? 0) is num
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0,
    );
  }
}
