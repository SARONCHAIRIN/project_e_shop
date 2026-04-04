
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl = 'https://e-shop-1-m034.onrender.com/api/v1/orders';

  Future<List> fetchOrders(int userId, String token) async {
    final url = Uri.parse("$baseUrl/user/$userId");

    try {
      final response = await http.get(
          url,
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          }

      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['content']; //  FIX HERE

        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch orders : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch orders : $e');
    }

  }


  //checkout
  Future<bool> checkout(
      int userId,
      String token,
      int address_id,
      String payment_method,
      ) async {
    final url = await Uri.parse(
      "$baseUrl/user/$userId/from-cart",
    );
    try{
      final reponse = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            "address_id" : address_id,
          "payment_method" : payment_method,
          }
      ),
      );
      print("STATUS: ${reponse.statusCode}");
      print("BODY: ${reponse.body}");

      return reponse.statusCode == 200 || reponse.statusCode == 201;

    }catch(e){
      throw Exception('Failed to checkout : $e');
    }
  }

  //cancel Order
 Future<bool> cancelOrder(
     int orderId,
     int userId,
      String token,
     
     ) async {
    final url = await Uri.parse(
      "$baseUrl/$orderId/user/$userId/cancel",
    );
    try{
      final reponse = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization ': "Beater $token",
        }
      );
      return reponse.statusCode == 200 || reponse.statusCode == 201;
      
    }catch(e){
      throw Exception('Failed to cancel order : $e');
    }
 }
}