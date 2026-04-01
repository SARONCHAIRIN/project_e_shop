// // lib/data/repositories/auth_repository.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class AuthRepository {
//   final String baseUrl = 'https://your-api-url.com'; // Replace with your API URL
//
//   // Login API call
//   Future<Map<String, dynamic>> login(String username, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'username': username,
//           'password': password,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         return {
//           'success': true,
//           'token': json.decode(response.body)['token'],
//           'user': json.decode(response.body)['user'],
//         };
//       } else {
//         return {
//           'success': false,
//           'message': json.decode(response.body)['message'] ?? 'Login failed',
//         };
//       }
//     } catch (e) {
//       print('AuthRepository login error: $e');
//       return {
//         'success': false,
//         'message': 'Network error',
//       };
//     }
//   }
//
//   // Register API call
//   Future<Map<String, dynamic>> register({
//     required String username,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'username': username,
//           'email': email,
//           'password': password,
//         }),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'success': true,
//           'message': 'Registration successful',
//         };
//       } else if (response.statusCode == 400) {
//         return {
//           'success': false,
//           'message': json.decode(response.body)['message'] ??
//               'Username or email already exists',
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Registration failed',
//         };
//       }
//     } catch (e) {
//       print('AuthRepository register error: $e');
//       return {
//         'success': false,
//         'message': 'Network error',
//       };
//     }
//   }
// }
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  final dynamic service; // ឬ AuthService
  final TokenStorage storage;

  AuthRepository({
    required this.service,
    required this.storage,
  });

  // Login method
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print(' Login attempt for: $username');

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print(' Response status: ${response.statusCode}');
      print(' Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'userId': data['user']?['id'] ?? data['userId'] ?? 0,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed',
        };
      }
    } catch (e) {
      print(' Login error: $e');
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }

  //  Register method with fullName
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? fullName, // បន្ថែម fullName
  }) async {
    try {
      // រៀបចំ body សម្រាប់ផ្ញើទៅ API
      Map<String, dynamic> body = {
        'username': username,
        'email': email,
        'password': password,
      };

      // បើមាន fullName ទើបបន្ថែម
      if (fullName != null && fullName.isNotEmpty) {
        body['fullName'] = fullName;
        body['full_name'] = fullName;
      }

      print(' Register request: $body');

      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print(' Register response: ${response.statusCode}');
      print(' Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': data['user'],
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print(' Register error: $e');
      return {
        'success': false,
        'message': 'Network error',
      };
    }
  }

  // Logout method
  Future<void> logout() async {
    await storage.deleteToken();
    await storage.deleteUserId();
  }
}