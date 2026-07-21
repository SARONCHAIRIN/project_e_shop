class ProductApiResponse {
  final List<Product> payload;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  ProductApiResponse({
    required this.payload,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
    final dataBlock = json['data'] as Map<String, dynamic>? ?? {};

    final list = dataBlock['payload'] as List? ?? [];

    return ProductApiResponse(
      payload: list.map((e) => Product.fromJson(e)).toList(),
      // 👈 Parse ចូល Product ផ្ទាល់
      totalItems: dataBlock['total_items'] ?? 0,
      totalPages: dataBlock['total_pages'] ?? 0,
      currentPage: dataBlock['current_page'] ?? 1,
      pageSize: dataBlock['page_size'] ?? 10,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final List<String> mainImage;
  final bool isActive;
  final List<ProductSku> skus;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.mainImage,
    required this.isActive,
    required this.skus,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final skuList = json['skus'] as List? ?? [];

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      mainImage: List<String>.from(json['main_image'] ?? []),
      isActive: json['is_active'] ?? false,
      skus: skuList.map((e) => ProductSku.fromJson(e)).toList(),
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  double get lowestPrice {
    if (skus.isEmpty) return 0;
    return skus.map((e) => e.price).reduce((a, b) => a < b ? a : b);
  }

  ProductSku? get defaultSku {
    if (skus.isEmpty) return null;
    try {
      return skus.firstWhere((e) => e.isDefault);
    } catch (_) {
      return skus.first;
    }
  }
}

class ProductSku {
  final int id;
  final String sku;
  final String? description;
  final double price;
  final int? quantity;
  final List<String>? images;
  final bool isDefault;
  final List<ProductAttribute> attributes;

  ProductSku({
    required this.id,
    required this.sku,
    this.description,
    required this.price,
    this.quantity,
    this.images,
    required this.isDefault,
    required this.attributes,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] as int?,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isDefault: json['is_default'] ?? false,
      attributes: (json['attributes'] as List? ?? [])
          .map((e) => ProductAttribute.fromJson(e))
          .toList(),
    );
  }

  ProductAttribute? getAttribute(String name) {
    try {
      return attributes.firstWhere(
        (e) => e.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  String? getAttributeValue(String name) {
    final attr = getAttribute(name);
    if (attr == null || attr.values.isEmpty) return null;
    return attr.values.first.value;
  }
}

class ProductAttribute {
  final int id;
  final String name;
  final List<AttributeValue> values;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.values,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      values: (json['attributes'] as List? ?? [])
          .map((e) => AttributeValue.fromJson(e))
          .toList(),
    );
  }
}

class AttributeValue {
  final int id;
  final String value;

  AttributeValue({required this.id, required this.value});

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(id: json['id'] ?? 0, value: json['value'] ?? '');
  }
}
