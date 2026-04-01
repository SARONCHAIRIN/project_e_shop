import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/user/get_user_model.dart';
class GetUserIdService {
  Future<GetUserModel?> getUserById(int id, String token) async {
    try {
      final res = await http.get(
        Uri.parse('https://e-shop-1-m034.onrender.com/api/v1/user/$id/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body);

      //  IMPORTANT
      final data = body['data'];

      return GetUserModel.fromJson(data);
    } catch (e) {
      print("ERROR: $e");
      return null;
    }
  }
}