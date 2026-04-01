import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/repositories/auth/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  Map<String, dynamic>? _userData;

  AuthController({
    required this.authRepository,
    required this.tokenStorage,
  });

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  // Check login status when app starts
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await tokenStorage.readToken();
      _isAuthenticated = _token != null && _token!.isNotEmpty;

      if (_isAuthenticated) {
        // Optionally validate token with backend
        print(' User is authenticated with token: $_token');
      } else {
        print(' No valid token found');
      }
    } catch (e) {
      print('Error checking login status: $e');
      _isAuthenticated = false;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login function
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Call your login API
      final response = await authRepository.login(username, password);

      if (response['success'] == true) {
        _token = response['token'];
        _userData = response['user'];
        _isAuthenticated = true;

        // Save token
        await tokenStorage.saveToken(_token!);

        print(' Login successful, token: $_token');
        return true;
      } else {
        print(' Login failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register function
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await authRepository.register(
        username: username,
        email: email,
        password: password,
      );

      if (response['success'] == true) {
        print(' Registration successful');
        return true;
      } else {
        print(' Registration failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout function
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await tokenStorage.deleteToken();
      _token = null;
      _userData = null;
      _isAuthenticated = false;

      print(' Logout successful');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}