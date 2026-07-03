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

final localDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      // ip angkor home
      // baseUrl: "http://localhost:8080", // local backend
      baseUrl: "http://192.168.18.61:8080", // local backend
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );
});

final serverDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: "https://e-shop-1-m034.onrender.com", // real server
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );
});

// Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    localDio: ref.read(localDioProvider),
    serverDio: ref.read(serverDioProvider),
  );
});
// Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.read(authServiceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});
// Auth Controller (StateNotifier)
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(authRepositoryProvider));
  },
);
