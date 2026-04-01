import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/subcategory_model_eshop.dart';

class ApiService {
  static const String baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1';

  Future<List<SubcategoryData>> fetchSubcategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/subcategories/All'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("status : ${response.statusCode}");
      print("API Data : ${response.body}");
      // If the server returns a 200 OK response, parse the JSON
      var jsonResponse = jsonDecode(response.body);
      SubcategoryApiResponse apiResponse = SubcategoryApiResponse.fromJson(jsonResponse);

      // Extract the list of SubcategoryData from the content
      List<SubcategoryData> subcategories =
      apiResponse.content.map((item) => item.data).toList();

      return subcategories;
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to load subcategories. Status code: ${response.statusCode}');
    }
  }


  // Optional: Fetch a single subcategory by ID
  Future<SubcategoryData> fetchSubcategoryById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subcategories/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      // Assuming the API returns a similar structure for single item
      return SubcategoryData.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load subcategory. Status code: ${response.statusCode}');
    }
  }
}