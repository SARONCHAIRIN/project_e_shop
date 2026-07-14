


import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/storage/token_storage.dart';
import '../../models/product_model_eshop.dart';
import '../../models/subcategory_model_eshop.dart';

class ApiService {
  // static const String baseUrl = 'http://localhost:8080/api/v1';

  static String baseUrl = "https://e-shop-1-m034.onrender.com/api/v1";


  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage().readToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
// ==========================================
  // 1. ទាញយក SUBCATEGORIES ទាំងអស់ (កែសម្រួលជាន់ JSON ទៅជា 'data')
  // ==========================================
  Future<List<SubcategoryData>> fetchSubcategories() async {
    final url = Uri.parse('$baseUrl/subcategories/get/all');

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        "criteria_type": 0,
        "criteria_value": "",
        "page": 1,
        "size": 100
      }),
    );

    print("SUB-CATEGORY STATUS: ${response.statusCode}");
    print("SUB-CATEGORY BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // កែពី jsonResponse['payload'] ទៅជា jsonResponse['data'] វិញឲ្យត្រូវនឹងសាច់ទិន្នន័យជាក់ស្តែង
      final dataStructure = jsonResponse['data'];
      final List content = (dataStructure != null) ? (dataStructure['payload'] ?? []) : [];

      return content
          .map((item) => SubcategoryData.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  // ==========================================
  // 2. ទាញយក PRODUCTS (កែសម្រួលជាន់ JSON ទៅជា 'data' ដូចគ្នា)
  // ==========================================
  Future<List<Product>> fetchProductsBySubcategoryId(int subcategoryId) async {
    final url = Uri.parse('$baseUrl/products/get/all');

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        "criteria_type": 2,
        "criteria_value": subcategoryId.toString(),
        "page": 1,
        "size": 100
      }),
    );

    print("PRODUCTS STATUS => ${response.statusCode}");
    print("PRODUCTS BODY => ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      try {
        // កែទៅជា 'data' ដើម្បីការពារ Error ដូចគ្នាប្រសិនបើ Product API ប្រើប្រាស់ Structure ដូច Subcategory
        final dataStructure = jsonResponse['data'] ?? jsonResponse['payload'];
        final List<dynamic> contentList = (dataStructure != null) ? (dataStructure['payload'] ?? []) : [];

        return contentList
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e, st) {
        print("PARSE ERROR IN PRODUCTS => $e");
        print(st);
        rethrow;
      }
    }
    throw Exception('Failed to load products');
  }
  // ==========================================
  // 3. ចម្រោះ SUBCATEGORIES តាមរយៈ CATEGORY ID ឬ ឈ្មោះ
  // ==========================================

  // វិធីសាស្ត្រល្អបំផុត (Best Practice): ចម្រោះតាម Category ID ផ្ទាល់ពី Server ដោយប្រើ criteria_type: 2
  Future<List<SubcategoryData>> fetchSubcategoriesByCategoryId(int categoryId) async {
    final url = Uri.parse('$baseUrl/subcategories/get/all');

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        "criteria_type": 2, // Filter by category ID
        "criteria_value": categoryId.toString(),
        "page": 1,
        "size": 100
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List content = jsonResponse['payload']['payload'] ?? [];
      return content
          .map((item) => SubcategoryData.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load subcategories by category id');
    }
  }

  // វិធីសាស្ត្រចាស់ (Local Filter): ទាញមកទាំងអស់ រួចចម្រោះតាមឈ្មោះនៅលើ App
  Future<List<SubcategoryData>> fetchSubcategoriesByCategoryName(String categoryName) async {
    final allSubcategories = await fetchSubcategories();
    print("CATEGORY FILTER NAME: $categoryName");

    if (categoryName == 'All' || categoryName.isEmpty) {
      return allSubcategories;
    }

    return allSubcategories
        .where(
          (sub) => sub.categoryName.trim().toLowerCase() == categoryName.trim().toLowerCase(),
    )
        .toList();
  }
}