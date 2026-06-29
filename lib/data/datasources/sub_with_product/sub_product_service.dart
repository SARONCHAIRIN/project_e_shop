import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/storage/token_storage.dart';
import '../../models/product_model_eshop.dart';
import '../../models/subcategory_model_eshop.dart';

class ApiService {
  static const String baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';


  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  // Get all subcategories
  Future<List<SubcategoryData>> fetchSubcategories() async {

    final response = await http.post(
      // Uri.parse('http://localhost:8080/api/v1/subcategories/All?page=0&size=100&sort=DESC'),
        Uri.parse('$baseUrl/subcategories/All?page=0&size=100&sort=name%2Cdesc'),
      // Uri.parse('$baseUrl/subcategories/All?page=0&size=100&sort=DESC'),
      headers: await _getHeaders(),
    );


    print("STATUS: ${response.statusCode}");

    print("BODY: ${response.body}");
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
    final token = await TokenStorage().readToken();

    print("TOKEN => $token");

    final uri = Uri.parse(
        '$baseUrl/products/subcategory/id'
    ).replace(
      queryParameters: {
        'subCategoryId': subcategoryId.toString(),
        'page': '0',
        'size': '100',
        'sort': 'name,desc',
      },
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print("URL => $uri");
    print("STATUS => ${response.statusCode}");
    print("BODY => ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> contentList = jsonResponse['content'];

      try {
        return contentList
            .map((e) => Product.fromJson(e['data'] as Map<String, dynamic>))
            .toList();
      } catch (e, st) {
        print(" PARSE ERROR => $e");
        print(st);
        rethrow;
      }
    }

    throw Exception('Failed to load products');
  }



  Future<List<SubcategoryData>> fetchSubcategoriesByCategoryName(
    String categoryName,
  ) async {
    final allSubcategories = await fetchSubcategories();
    print("CATEGORY: ${categoryName}");

    if (categoryName == 'All') {
      return allSubcategories; //  show all
    }

    return allSubcategories
        .where(
          (sub) =>
              sub.categoryName.trim().toLowerCase() ==
              categoryName.trim().toLowerCase(),
        )
        .toList();
  }
}
