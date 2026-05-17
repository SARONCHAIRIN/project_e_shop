/*
// Model representing a single item in an order
class OrderItemModel {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  OrderItemModel({
	required this.id,
	required this.productId,
	required this.name,
	required this.price,
	required this.quantity,
	this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
	return OrderItemModel(
	  id: json['id'] ?? 0,
	  productId: json['product_id'] ?? json['productId'] ?? 0,
	  name: json['name'] ?? '',
	  price: (json['price'] ?? 0).toDouble(),
	  quantity: json['quantity'] ?? 0,
	  image: json['image'] as String?,
	);
  }

  Map<String, dynamic> toJson() {
	return {
	  'id': id,
	  'product_id': productId,
	  'name': name,
	  'price': price,
	  'quantity': quantity,
	  'image': image,
	};
  }
}


*/



class OrderItemModel {
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final ProductSkuModel productSku;

  OrderItemModel({
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productSku,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      quantity: json['quantity'] ?? 0,
      unitPrice:
      (json['unit_price'] ?? 0).toDouble(),
      totalPrice:
      (json['total_price'] ?? 0).toDouble(),
      productSku: ProductSkuModel.fromJson(
        json['product_sku'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'product_sku': productSku.toJson(),
    };
  }
}


// product_sku_model.dart

class ProductSkuModel {
  final int id;
  final String sku;
  final String description;
  final double price;
  final String color;
  final String size;
  final int quantity;

  ProductSkuModel({
    required this.id,
    required this.sku,
    required this.description,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory ProductSkuModel.fromJson(Map<String, dynamic> json) {
    return ProductSkuModel(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'description': description,
      'price': price,
      'color': color,
      'size': size,
      'quantity': quantity,
    };
  }
}