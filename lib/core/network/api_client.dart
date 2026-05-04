
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiClient {
  final http.Client _client;
  ApiClient([http.Client? client]) : _client = client ?? http.Client();


  //function get api
  Future<Map<String , dynamic >>  get(
      String url,
  {Map<String , String>? headers }) async{
    final res = await _client.get(
      Uri.parse(url),
      headers: {'content-type': 'application/json', ...?headers},
    );

    final decoded = jsonDecode(res.body.isNotEmpty ? res.body : '{}');
    print('response body ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'HTTP ${res.statusCode}';
      throw Exception(message);
    }

    return decoded as Map<String, dynamic>;
  }

  //function api  post
  Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    print('POST URL: $url');
    print('POST BODY: ${jsonEncode(body)}');
    final res = await _client.post(
      Uri.parse(url),
      headers: {'content-type': 'application/json', ...?headers},
      body: jsonEncode(body),
    );
    print('RESPONSE STATUS: ${res.statusCode}');
    print('RESPONSE BODY: ${res.body}');

    final decoded = jsonDecode(res.body.isNotEmpty ? res.body : '{}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final message = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'HTTP ${res.statusCode}';


      throw Exception(message);
    }

    return decoded as Map<String, dynamic>;
  }


  //header
  static Future<Map<String, String>> headers() async {
    final token = await TokenStorage().readToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}