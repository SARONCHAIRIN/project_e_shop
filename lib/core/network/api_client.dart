/*
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'interceptors/auth_interceptors.dart';
import '../storage/token_storage.dart';

/// Production-ready API client using Dio with interceptors.
/// 
/// Features:
/// - Automatic token injection in request headers
/// - Automatic token refresh on 401 (Unauthorized) responses
/// - Request/response logging for debugging
/// - Centralized error handling
class ApiClient {
  final Dio dio;
  final TokenStorage _tokenStorage;

  ApiClient._internal(this.dio, this._tokenStorage);

  factory ApiClient({TokenStorage? storage}) {
    final baseUrl = dotenv.env['BASE_URL'] ?? 'https://e-shop-1-m034.onrender.com';
    
    final tokenStorage = storage ?? TokenStorage();

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Attach interceptors
    dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage, dio: dio));

    return ApiClient._internal(dio, tokenStorage);
  }

  /// Get current access token from secure storage.
  Future<String?> getAccessToken() => _tokenStorage.readToken();

  /// Get current refresh token from secure storage.
  Future<String?> getRefreshToken() => _tokenStorage.readRefreshToken();

  /// Logout: clear all stored tokens and user data.
  Future<void> logout() => _tokenStorage.clearAll();
}



*/
//network = communication api and internet
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiClient {
  final http.Client _client;

  //constructor
  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  //function get api
  Future<Map<String, dynamic>> get(
      String url, {
        Map<String, String>? headers,
      }) async {
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
      String url,
      Map<String, dynamic> body, {
        Map<String, String>? headers,
      }) async {
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