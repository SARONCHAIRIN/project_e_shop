class ProductSKU {
  final String sku;
  final String description;
  final int price;
  final String color;
  final String size;
  final int quantity;

  ProductSKU({
    required this.sku,
    required this.description,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory ProductSKU.fromJson(Map<String, dynamic> json) {
    return ProductSKU(
      sku: json['sku'],
      description: json['description'],
      price: json['price'],
      color: json['color'],
      size: json['size'],
      quantity: json['quantity'],
    );
  }
}