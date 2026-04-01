// // lib/services/storage_service.dart
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// class StorageService {
//   static const String _tokenKey = 'auth_token';
//   static const String _userKey = 'user_data';
//
//   // Save token
//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//     print('Token saved successfully');
//   }
//
//   // Get token
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }
//
//   // Clear token
//   static Future<void> clearToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     print('Token cleared');
//   }
//
//   // Save user data
//   static Future<void> saveUserData(Map<String, dynamic> userData) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userKey, json.encode(userData));
//   }
//
//   // Get user data
//   static Future<Map<String, dynamic>?> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? userString = prefs.getString(_userKey);
//     if (userString != null) {
//       return json.decode(userString);
//     }
//     return null;
//   }
//
//   // Clear user data
//   static Future<void> clearUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_userKey);
//   }
//
//   // Check if user is logged in
//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     return token != null;
//   }
// }