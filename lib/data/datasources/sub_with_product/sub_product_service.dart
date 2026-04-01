import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/product_model_eshop.dart';
import '../../models/subcategory_model_eshop.dart';

class ApiService {
  static const String baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  // Get all subcategories
  Future<List<SubcategoryData>> fetchSubcategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subcategories/All'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List content = jsonResponse['content'];
      return content
          .map((item) => SubcategoryData.fromJson(item['data']))
          .toList();
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  // Get products by subcategory id
  Future<List<Product>> fetchProductsBySubcategoryId(int subcategoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/subcategory/$subcategoryId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      List content = jsonResponse['content'];
      return content
          .map((item) => Product.fromJson(item['data']))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}