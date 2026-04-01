// data/datasources/cart/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/cart/cart_model.dart';

class CartService {
  final String baseUrl = "https://e-shop-1-m034.onrender.com/api/v1/cart";

  // GET cart
  Future<CartModel> getCart(int userId, String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return CartModel.fromJson(data);
    }
    throw Exception("Failed to fetch cart");
  }

  // POST add item
  // Future<void> addItem(int userId,  int quantity, int productId,String token) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/user/$userId/items"),
  //     headers: {
  //       // 'accept ': 'application/json',
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json"},
  //     body: jsonEncode({
  //       "quantity": quantity,
  //       "product_id": productId,
  //
  //     }),
  //   );
  //   if (response.statusCode != 201) throw Exception("Failed to add item");
  // }

  Future<void> addItem(int userId, int productId, int quantity, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user/$userId/items"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "product_id": productId,
        "quantity": quantity,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");

    if (response.statusCode != 201) {
      throw Exception("Failed to add item");
    }
  }
  Future<void> updateItem(
      int userId,
      int cartItemId,
      int quantity,
      String token
      ) async {
    final url = Uri.parse('https://e-shop-1-m034.onrender.com/api/v1/cart/user/$userId/items/$cartItemId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        "Accept": "application/json",

      },
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Update failed: ${response.body}');
      throw Exception('Failed to update item');
    }

    print('Update success: ${response.body}');
  }
  // DELETE single item
  Future<void> deleteItem(int userId, int cartItemId, String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/user/$userId/items/$cartItemId"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 200) throw Exception("Failed to delete item");
  }

  // DELETE clear cart
  Future<void> clearCart(int userId, String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/user/$userId/clear"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 200) throw Exception("Failed to clear cart");
  }
}