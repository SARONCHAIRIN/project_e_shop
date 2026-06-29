// // Product SKU model
// class ProductSku {
//   final String sku;
//   final String? description;
//   final double price;
//   final String? color;
//   final String? size;
//   final int quantity;
//
//   ProductSku({
//     required this.sku,
//     this.description,
//     required this.price,
//     this.color,
//     this.size,
//     required this.quantity,
//   });
//
//   factory ProductSku.fromJson(Map<String, dynamic> json) {
//     return ProductSku(
//       sku: json['sku'] ?? '',
//       description: json['description'],
//       price: (json['price'] ?? 0).toDouble(),
//       color: json['color'],
//       size: json['size'],
//       quantity: json['quantity'] ?? 0,
//     );
//   }
// }
//
// // Product model
// class Product {
//   final int id;
//   final String name;
//   // final String sku;
//   final String description;
//   final List<String> mainImage;
//   final bool isActive;
//   final List<ProductSku> skus;
//   bool isFavorite  ;
//
//   Product({
//     required this.id,
//     required this.name,
//     // required this.sku,
//     required this.description,
//     required this.mainImage,
//     required this.isActive,
//     required this.skus,
//      this.isFavorite = false,
//   });
//
//   // factory Product.fromJson(Map<String, dynamic> json) {
//   //   var skusList = json['skus'] as List? ?? [];
//   //   List<ProductSku> skus =
//   //   skusList.map((sku) => ProductSku.fromJson(sku)).toList();
//   //
//   //   return Product(
//   //     id: json['id'],
//   //     name: json['name']?.toString() ?? '',
//   //     // sku: json['sku'],
//   //     description: json['description'],
//   //     // mainImage: json['main_image']?.toString()?? "",
//   //     mainImage: List<String>.from(json['main_image'] ?? []),
//   //     isActive: json['is_active'] ?? false,
//   //     skus: skus,
//   //     isFavorite:  json['is_favorite'] ?? false,
//   //   );
//   // }
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     var skusList = (json['skus'] ?? []) as List;
//
//     return Product(
//       id: json['id'] ?? 0,
//       name: json['name']?.toString() ?? '',
//       description: json['description']?.toString() ?? '',
//       mainImage: List<String>.from(json['main_image'] ?? []),
//       isActive: json['is_active'] == true,
//       isFavorite: json['is_favorite'] ?? false,
//       skus: skusList.map((sku) => ProductSku.fromJson(sku)).toList(),
//     );
//   }
//   // Get lowest price from SKUs
//   double get lowestPrice {
//     if (skus.isEmpty) return 0.0;
//     return skus.map((sku) => sku.price).reduce((a, b) => a < b ? a : b);
//   }
// }
//
// // API Response wrapper for products
//
// // class ProductApiResponse {
// //   final List<ProductItem> content;
// //   final bool empty;
// //   final bool first;
// //   final bool last;
// //   final int number;
// //   final int numberOfElements;
// //   final int size;
// //   final int totalElements;
// //   final int totalPages;
// //
// //   ProductApiResponse({
// //     required this.content,
// //     required this.empty,
// //     required this.first,
// //     required this.last,
// //     required this.number,
// //     required this.numberOfElements,
// //     required this.size,
// //     required this.totalElements,
// //     required this.totalPages,
// //   });
// //
// //   factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
// //     var list = json['content'] as List;
// //     List<ProductItem> contentList =
// //     list.map((i) => ProductItem.fromJson(i)).toList();
// //
// //     return ProductApiResponse(
// //       content: contentList,
// //       empty: json['empty'],
// //       first: json['first'],
// //       last: json['last'],
// //       number: json['number'],
// //       numberOfElements: json['numberOfElements'],
// //       size: json['size'],
// //       totalElements: json['totalElements'],
// //       totalPages: json['totalPages'],
// //     );
// //   }
// // }
//
// class ProductApiResponse {
//   final String message;
//   final String code;
//   final Product data;
//
//   ProductApiResponse({
//     required this.message,
//     required this.code,
//     required this.data,
//   });
//
//   factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
//     return ProductApiResponse(
//       message: json['message'] ?? '',
//       code: json['code'] ?? '',
//       data: Product.fromJson(json['data'] ?? {}),
//     );
//   }
// }
//
// // class ProductItem {
// //   final String message;
// //   final String code;
// //   final Product data;
// //
// //   ProductItem({
// //     required this.message,
// //     required this.code,
// //     required this.data,
// //   });
// //
// //   factory ProductItem.fromJson(Map<String, dynamic> json) {
// //     return ProductItem(
// //       message: json['message'],
// //       code: json['code'],
// //       data: Product.fromJson(json['data']),
// //     );
// //   }
// // }



class ProductApiResponse {
  final List<ProductItem> content;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final int number;
  final int numberOfElements;
  final bool empty;

  ProductApiResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.number,
    required this.numberOfElements,
    required this.empty,
  });

  factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
    return ProductApiResponse(
      content: (json['content'] as List? ?? [])
          .map((e) => ProductItem.fromJson(e))
          .toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? false,
      last: json['last'] ?? false,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? false,
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
      message: json['message'] ?? '',
      code: json['code'] ?? '',
      data: Product.fromJson(json['data'] ?? {}),
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

    return skus
        .map((e) => e.price)
        .reduce((a, b) => a < b ? a : b);
  }

  ProductSku? get defaultSku {
    if (skus.isEmpty) return null;

    return skus.firstWhere(
          (e) => e.isDefault,
      orElse: () => skus.first,
    );
  }
}


// class ProductSku {
//   final int id;
//   final String sku;
//   final String? description;
//   final double price;
//   final int quantity;
//   final bool isDefault;
//
//   final String? color;
//   final String? size;
//
//   ProductSku({
//     required this.id,
//     required this.sku,
//     this.description,
//     required this.price,
//     required this.quantity,
//     required this.isDefault,
//     this.color,
//     this.size,
//   });
//
//   factory ProductSku.fromJson(Map<String, dynamic> json) {
//     String? color;
//     String? size;
//
//     final groups = json['attributes'] as List? ?? [];
//
//     for (final group in groups) {
//       final name = (group['name'] ?? '').toString().toLowerCase();
//
//       final values = group['attributes'] as List? ?? [];
//
//       if (values.isEmpty) continue;
//
//       final value = values.first['value']?.toString();
//
//       if (name == 'color') {
//         color = value;
//       } else if (name == 'size') {
//         size = value;
//       }
//     }
//
//     return ProductSku(
//       id: json['id'] ?? 0,
//       sku: json['sku'] ?? '',
//       description: json['description'],
//       price: (json['price'] as num?)?.toDouble() ?? 0,
//       quantity: json['quantity'] ?? 0,
//       isDefault: json['is_default'] ?? false,
//       color: color,
//       size: size,
//     );
//   }
// }

class ProductSku {
  final int id;
  final String sku;
  final String? description;
  final double price;
  final int quantity;
  final bool isDefault;

  final List<ProductAttribute> attributes;

  ProductSku({
    required this.id,
    required this.sku,
    this.description,
    required this.price,
    required this.quantity,
    required this.isDefault,
    required this.attributes,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 0,
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

class AttributeValue {
  final int id;
  final String value;

  AttributeValue({
    required this.id,
    required this.value,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      id: json['id'] ?? 0,
      value: json['value'] ?? '',
    );
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