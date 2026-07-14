import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/cart/cart_model.dart';

class CartService {
  final String baseUrl = "https://e-shop-1-m034.onrender.com/api/v1/cart";

  // final String baseUrl = "http://10.1.121.208:8080/api/v1/cart";


  // final String baseUrl = "http://localhost:8080/api/v1/cart";

  // GET cart
  Future<CartModel> getCart(int userId, String token) async {
    final response = await http.post(
      // Uri.parse("$baseUrl/user/$userId"),
      Uri.parse("$baseUrl/user/id?userId=$userId"),
      // GET /user/id?userId=$userId
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print("GET CART URL => $baseUrl/user/$userId");
    print("GET CART STATUS => ${response.statusCode}");
    print("GET CART BODY => ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return CartModel.fromJson(data);
    }
    throw Exception("Failed to fetch cart");
  }

  Future<void> addItem(
    int userId,
    int productId,
    int quantity,
    String token,
  ) async {
    final response = await http.post(
      // Uri.parse("$baseUrl/user/$userId/items"),
      Uri.parse("$baseUrl/user/id/items?userId=$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"product_id": productId, "quantity": quantity}),


    );

    print("toen test===========: $token");
    print("STATUS: ${response.statusCode}");
    print("RESPONSE: ${response.body}");


    if (response.statusCode != 201) {
      throw Exception("Failed to add item");
    }
  }

  Future<void> updateItem(
      int userId,
      int cartItemId,
      int productId,
      int quantity,
      String token,
      ) async {
    final url = Uri.parse(
      "$baseUrl/user/id/items/cartItemId?userId=$userId&cartItemId=$cartItemId",
    );

    final body = {
      "product_id": productId,
      "quantity": quantity,
    };

    print("REQUEST URL => $url");
    print("REQUEST BODY => ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    print("STATUS => ${response.statusCode}");
    print("BODY => ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to update item: ${response.body}");
    }
  }


  // DELETE single item
  Future<void> deleteItem(int userId, int cartItemId, String token) async {
    final response = await http.post(
      Uri.parse(
        "$baseUrl/user/userId/items/cartItemId?userId=$userId&cartItemId=$cartItemId",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to delete item");
    }
  }
  // DELETE clear cart
  Future<void> clearCart(int userId, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user/userId/clear?userId=$userId"),
      //new enpoint
      // /user/id/clear?userId=$userId
      headers: {
        "Authorization": "Bearer $token",
        "accept" : '*/*',
      },
    );
    if (response.statusCode != 200) throw Exception("Failed to clear cart");
  }
}

