class OrderItemModel {
  final int id;
  final int quantity;
  final String productName;
  final double unitPrice;
  final double totalPrice;
  final ProductSkuModel productSku;

  OrderItemModel({
    required this.id,
    required this.quantity,
    required this.productName,
    required this.unitPrice,
    required this.totalPrice,
    required this.productSku,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      productName: json['product_name'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      productSku: ProductSkuModel.fromJson(
        json['product_sku'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'product_name': productName,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'product_sku': productSku.toJson(),
    };
  }
}

/// Attribute value, e.g. { "id": 4, "value": "តូច" }
class AttributeValue {
  final int id;
  final String value;

  AttributeValue({required this.id, required this.value});

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: (json['id'] as num?)?.toInt() ?? 0,
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'value': value};
}

class AttributeGroup {
  final int id;
  final String name;
  final List<AttributeValue> attributes;

  AttributeGroup({
    required this.id,
    required this.name,
    required this.attributes,
  });

  factory AttributeGroup.fromJson(Map<String, dynamic> json) {
    final list = json['attributes'] as List<dynamic>? ?? [];
    return AttributeGroup(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      attributes: list
          .map((e) => AttributeValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'attributes': attributes.map((e) => e.toJson()).toList(),
  };
}

class ProductSkuModel {
  final int id;
  final String sku;
  final String description;
  final double price;
  final int quantity;
  final bool operatorProductAttribute;
  final bool isDefault;
  final String? imageUrl;
  final List<AttributeGroup> attributes;

  ProductSkuModel({
    required this.id,
    required this.sku,
    required this.description,
    required this.price,
    required this.quantity,
    this.operatorProductAttribute = false,
    this.isDefault = false,
    this.imageUrl,
    this.attributes = const [],
  });

  factory ProductSkuModel.fromJson(Map<String, dynamic> json) {
    final attrList = json['attributes'] as List<dynamic>? ?? [];
    return ProductSkuModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      sku: json['sku'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      operatorProductAttribute:
          json['operatorProductAttribute'] as bool? ?? false,
      isDefault: json['is_default'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      attributes: attrList
          .map((e) => AttributeGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'description': description,
      'price': price,
      'quantity': quantity,
      'operatorProductAttribute': operatorProductAttribute,
      'is_default': isDefault,
      'image_url': imageUrl,
      'attributes': attributes.map((e) => e.toJson()).toList(),
    };
  }

  /// Convenience: flatten all attribute values into a display string
  String get displayAttributes => attributes
      .map((g) => '${g.name}: ${g.attributes.map((a) => a.value).join(", ")}')
      .join(' | ');
}
