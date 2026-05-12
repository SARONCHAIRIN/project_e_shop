import 'package:e_shop/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import '../../core/storage/token_storage.dart';
import '../datasources/user_auth_service.dart';
import '../models/user_model.dart';
import 'dart:developer' as developer;

class User_AuthRepository {
  final AuthService service;
  final TokenStorage storage;

  User_AuthRepository({
    required this.service,
    required this.storage,
  });

  // LOGIN
  Future<UserModel> login(
      String username,
      String password
      ) async {
    try {
      final res = await service.login(username, password);
      final user = UserModel.fromJson(res, loginUsername: username);

      if (user.token.isEmpty) throw Exception('No token returned from API');


      // Save user info
      await storage.writeToken(user.token);
      await storage.writeUserId(user.id);
      await storage.writeUsername(user.username);
      await storage.writeUserEmail(user.email);
      await storage.writePassword(password); // Save password for auto re-login

      //  Save refresh_token
      if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
        await storage.writeRefreshToken(user.refreshToken!);
        print('Refresh token saved during login: ${user.refreshToken}');
      }


      print("Login saved user: ${user.username}, token: ${user.token}");
      return user;
    } catch (e) {
      throw Exception('Login Error: $e');
    }
  }

  // REGISTER
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async
  {
    try {
      // Call register API
      final res = await service.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      print("REGISTER RAW RESPONSE: $res");

      // Parse UserModel from register response
      final user = UserModel.fromJson(res);

      // Save user info to storage
      await storage.writeToken(user.token);
      await storage.writeUserId(user.id);
      await storage.writeUsername(user.username);
      await storage.writeUserEmail(user.email);

      if (user.fullName != null) await storage.saveFullName(user.fullName!);


      //  Save refresh_token
      if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
        await storage.writeRefreshToken(user.refreshToken!);
        print('Refresh token saved during registration: ${user.refreshToken}');
      }

      print('Saved fullName : ${user.fullName}');

      // Return user directly instead of calling login
      return user;

    } catch (e) {
      print("REGISTER ERROR: $e");
      rethrow;
    }
  }


// AUTO RE-LOGIN
  Future<bool> autoReLogin() async {
    final username = await storage.readUsername();
    final password = await storage.readPassword(); // save when login
    print('Re-login username: $username');
    print('Re-login password: $password');
    if (username == null || password == null) return false;

    try {
      await login(username, password);
      print('Auto re-login success ');
      return true;
    } catch (e) {
      print('Auto re-login failed: $e');
      return false;
    }
  }

// AUTHENTICATED GET
  Future<http.Response?> authenticatedGet(String endpoint) async {
    var token = await storage.readToken();
    final url = Uri.parse('${ApiConstants.BASE_URL}$endpoint');
    print('GET: $url');

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );



    if (response.statusCode == 401) {
      print('401 → auto re-login...');
      final success = await autoReLogin();

      if (success) {
        token = await storage.readToken();
        response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        print('Retry: ${response.statusCode}');
      } else {
        await logout();
        return null;
      }
    }

    return response;
  }

  // LOGOUT
  Future<void> logout() async {
    await storage.deleteToken();
    await storage.deleteUsername();
    await storage.deleteUserImage();
    await storage.deleteRefreshToken();
    await storage.deletePassword();
    await storage.deleteUserId();
    print('User logged out, all data cleared');
  }

  // CHECK STORED DATA
  Future<void> checkStoredData() async {
    try {
      final allData = await storage.getAllUserInfo();
      developer.log("========== STORED DATA ==========");
      developer.log("Token: ${allData['token']?.toString().substring(0, 20)}...");
      developer.log("Username: ${allData['username']}");
      developer.log("Email: ${allData['email']}");
      developer.log("UserId: ${allData['userId']}");
      developer.log("Has Token: ${allData['token'] != null}");
      developer.log("=================================");
    } catch (e) {
      developer.log('Error checking stored data: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<int?> getCurrentUserId() async => await storage.readUserId();
  Future<String?> getCurrentUsername() async => await storage.readUsername();
}