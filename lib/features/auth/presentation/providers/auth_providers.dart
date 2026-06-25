import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

/// ==============================
/// CORE PROVIDERS
/// ==============================

// Token Storage
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

// Dio / ApiClient
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:8080", // change to your backendx
      // baseUrl:  "http://192.168.1.15:8080", // change to your backend
      // baseUrl: "https://e-shop-1-m034.onrender.com", // change to your backend
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {

        "Content-Type": "application/json",

        "Accept": "application/json",

      },
    ),
  );

  // dio.interceptors.add(
  //   LogInterceptor(
  //     request: true,
  //     requestHeader: true,
  //     requestBody: true,
  //     responseBody: true,
  //     error: true,
  //   ),
  // );

  return dio;
});

// Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(dio: ref.read(dioProvider));
});

// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.read(authServiceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

// Auth Controller (StateNotifier)
final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});
