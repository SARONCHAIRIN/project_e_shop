import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/storage/token_storage.dart';
import '../../models/category /category_model.dart';

class CategoryService {
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
  // ទាញយក CATEGORIES ទាំងអស់ (query params, មិនមែន body)
  // ==========================================
  Future<List<CategoryModel>> fetchCategories({
    int page = 0,
    int size = 100,
    String sort = 'DESC',
  }) async {
    final url = Uri.parse('$baseUrl/categories/get/all').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
        'sort': sort,
      },
    );

    final response = await http.post(url, headers: await _getHeaders());

    print("CATEGORY STATUS: ${response.statusCode}");
    print("CATEGORY BODY: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List content = jsonResponse['content'] ?? [];

      return content
          .map((item) => CategoryModel.fromJson(item['data'] as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}