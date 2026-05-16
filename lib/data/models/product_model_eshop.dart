// Product SKU model
class ProductSku {
  final String sku;
  final String description;
  final double price;
  final String? color;
  final String? size;
  final int quantity;

  ProductSku({
    required this.sku,
    required this.description,
    required this.price,
    required this.color,
    required this.size,
    required this.quantity,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      sku: json['sku'],
      description: json['description'],
      price: json['price'].toDouble(),
      color: json['color']?.toString()?? '',
      size: json['size']?? '',
      quantity: json['quantity'],
    );
  }
}

// Product model
class Product {
  final int id;
  final String name;
  // final String sku;
  final String description;
  final String mainImage;
  final bool isActive;
  final List<ProductSku> skus;
  bool isFavorite  ;

  Product({
    required this.id,
    required this.name,
    // required this.sku,
    required this.description,
    required this.mainImage,
    required this.isActive,
    required this.skus,
     this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var skusList = json['skus'] as List;
    List<ProductSku> skus = skusList.map((sku) => ProductSku.fromJson(sku)).toList();

    return Product(
      id: json['id'],
      name: json['name']?.toString() ?? '',
      // sku: json['sku'],
      description: json['description'],
      mainImage: json['main_image']?.toString()?? "",
      isActive: json['is_active'],
      skus: skus,
      isFavorite:  json['is_favorite'] ?? false,
    );
  }

  // Get lowest price from SKUs
  double get lowestPrice {
    if (skus.isEmpty) return 0.0;
    return skus.map((sku) => sku.price).reduce((a, b) => a < b ? a : b);
  }
}

// API Response wrapper for products
class ProductApiResponse {
  final List<ProductItem> content;
  final bool empty;
  final bool first;
  final bool last;
  final int number;
  final int numberOfElements;
  final int size;
  final int totalElements;
  final int totalPages;

  ProductApiResponse({
    required this.content,
    required this.empty,
    required this.first,
    required this.last,
    required this.number,
    required this.numberOfElements,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['content'] as List;
    List<ProductItem> contentList =
    list.map((i) => ProductItem.fromJson(i)).toList();

    return ProductApiResponse(
      content: contentList,
      empty: json['empty'],
      first: json['first'],
      last: json['last'],
      number: json['number'],
      numberOfElements: json['numberOfElements'],
      size: json['size'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
    );
  }
}

class ProductItem {
  final String message;
  final String code;
  final Product data;

  ProductItem({
    required this.message,
    required this.code,
    required this.data,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      message: json['message'],
      code: json['code'],
      data: Product.fromJson(json['data']),
    );
  }
}