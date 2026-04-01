import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/product_model_eshop.dart';

class ProductService {
  static const String baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  // // Fetch all products
  // Future<List<Product>> fetchAllProducts() async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/products'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     var jsonResponse = jsonDecode(response.body);
  //     ProductApiResponse apiResponse = ProductApiResponse.fromJson(jsonResponse);
  //     return apiResponse.content.map((item) => item.data).toList();
  //   } else {
  //     throw Exception('Failed to load products. Status code: ${response.statusCode}');
  //   }
  // }


  // product to cart
  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(
      Uri.parse(ApiConstants.products),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List content = jsonResponse['content'];
      return content.map((item) => Product.fromJson(item['data'])).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }


  // Search products by name (API)
  Future<List<Product>> searchProducts(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/search?name=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      ProductApiResponse apiResponse = ProductApiResponse.fromJson(jsonResponse);
      return apiResponse.content.map((item) => item.data).toList();
    } else {
      throw Exception('Failed to search products.');
    }
  }

  // Fetch products by category name (subcategory name)
  Future<List<Product>> fetchProductsByCategory(String categoryName) async {
    final allProducts = await fetchAllProducts();

    // Filter products by category_name
    // Note: This is client-side filtering. If the API supports server-side filtering,
    // it would be more efficient to use query parameters.
    return allProducts.where((product) {
      // You might need to adjust this based on how categories are stored in your products
      // For now, we're filtering by the category_name field in the product data
      return product.name.contains(categoryName) ||
          product.description.contains(categoryName);
    }).toList();
  }

  // product get by id to form subcategory
  Future<List<Product>> fetchProductsBySubcategoryId(int subcategoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/subcategory/$subcategoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      List content = jsonResponse['content'];

      List<Product> products = content
          .map((item) => Product.fromJson(item['data']))
          .toList();

      return products;
    } else {
      throw Exception(
          'Failed to load products. Status code: ${response.statusCode}');
    }
  }

  //method favorite
  Future<void> toggleFavorite({
    required int userId,
    required int productId,
    required bool isFavorite,
    required String token,
  })
  async {
    final url = Uri.parse('https://e-shop-1-m034.onrender.com/api/v1/users/$userId/favorite');
    final body = {
      'product_id': productId,
      'is_favorite': isFavorite,
    };
    print('POST body: $body');
    print('Headers: Authorization=Bearer $token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },

      body: jsonEncode(body),
    );
// Print server response for debug
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update favorite');
    }
  }

}

