import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/cart/cart_model.dart';

class CartService {
  final String baseUrl = "https://e-shop-1-m034.onrender.com/api/v1/cart";

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
    String token,
  )
  async {
    final url = Uri.parse(
      'https://e-shop-1-m034.onrender.com/api/v1/cart/user/$userId/items/$cartItemId',
      // 'https://e-shop-1-m034.onrender.com/api/v1/cart/user/id/items/$cartItemId?userId=$userId',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        "Accept": "application/json",
      },
      body: jsonEncode({'quantity': quantity, 'product_id': cartItemId}),
    );
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

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
      // /user/id/items/$cartItemId?userId=$userId
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 200) throw Exception("Failed to delete item");
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

//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import '../../models/cart/cart_model.dart';
//
// class CartService {
//   final String baseUrl = "https://e-shop-1-m034.onrender.com/api/v1/cart";
//
//   // POST /api/v1/cart/user/id   (getCartByUserId)
//   Future<CartModel> getCart(int userId, String token) async {
//     final url = Uri.parse("$baseUrl/user/id?userId=$userId");
//     final response = await http.post(
//       url,
//       headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
//     );
//
//     print("GET CART URL => $url");
//     print("GET CART STATUS => ${response.statusCode}");
//     print("GET CART BODY => ${response.body}");
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body)['data'];
//       return CartModel.fromJson(data);
//     }
//     throw Exception("Failed to fetch cart");
//   }
//
//   // POST /api/v1/cart/user/id/get-or-create   (getOrCreateCart)
//   Future<CartModel> getOrCreateCart(int userId, String token) async {
//     final url = Uri.parse("$baseUrl/user/id/get-or-create?userId=$userId");
//     final response = await http.post(
//       url,
//       headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
//     );
//
//     print("GET-OR-CREATE URL => $url");
//     print("GET-OR-CREATE STATUS => ${response.statusCode}");
//     print("GET-OR-CREATE BODY => ${response.body}");
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final data = json.decode(response.body)['data'];
//       return CartModel.fromJson(data);
//     }
//     throw Exception("Failed to get or create cart");
//   }
//
//   // POST /api/v1/cart/user/id/items   (addItemToCart)
//   Future<void> addItem(
//       int userId,
//       int productId,
//       int quantity,
//       String token,
//       ) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/user/id/items?userId=$userId"),
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode({"product_id": productId, "quantity": quantity}),
//     );
//
//     print("ADD ITEM STATUS: ${response.statusCode}");
//     print("ADD ITEM RESPONSE: ${response.body}");
//
//     if (response.statusCode != 201 && response.statusCode != 200) {
//       throw Exception("Failed to add item");
//     }
//   }
//   Future<void> updateItem(
//       int userId,
//       int cartItemId,
//       int productId,
//       int quantity,
//       String token,
//       ) async {
//     final url = Uri.parse(
//       "$baseUrl/user/id/items/cartItemId?userId=$userId&cartItemId=$cartItemId",
//     );
//
//     final requestBody = jsonEncode({'product_id': productId, 'quantity': quantity});
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//         "Accept": "application/json",
//       },
//       body: requestBody,
//     );
//
//     print("UPDATE URL => $url");
//     print("UPDATE REQUEST BODY => $requestBody");
//     print("UPDATE STATUS: ${response.statusCode}");
//     print("UPDATE BODY: ${response.body}");
//
//     if (response.statusCode != 200 && response.statusCode != 201) {
//       throw Exception('Failed to update item');
//     }
//   }
//
//   // POST /api/v1/cart/user/userId/items/cartItemId   (removeItemFromCart — note: POST, not DELETE)
//   Future<void> deleteItem(int userId, int cartItemId, String token) async {
//     final url = Uri.parse(
//       "$baseUrl/user/userId/items/cartItemId?userId=$userId&cartItemId=$cartItemId",
//     );
//
//     final response = await http.post(
//       url,
//       headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
//     );
//
//     print("DELETE ITEM URL => $url");
//     print("DELETE ITEM STATUS => ${response.statusCode}");
//     print("DELETE ITEM BODY => ${response.body}");
//
//     if (response.statusCode != 200) throw Exception("Failed to delete item");
//   }
//
//   // POST /api/v1/cart/user/userId/clear   (clearCart)
//   Future<void> clearCart(int userId, String token) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/user/userId/clear?userId=$userId"),
//       headers: {
//         "Authorization": "Bearer $token",
//         "accept": '*/*',
//       },
//     );
//     if (response.statusCode != 200) throw Exception("Failed to clear cart");
//   }
// }