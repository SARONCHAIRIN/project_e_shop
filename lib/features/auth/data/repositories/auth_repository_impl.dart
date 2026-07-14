import 'package:dio/dio.dart';

import '../../../../core/storage/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_service.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.authService,
    required this.tokenStorage,
  });

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final res = await authService.login(
      request.identifier,
      request.password,
    );

    final data = AuthResponse.fromJson(res.data);

    await _saveTokens(data);

    return data;
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final Response res = await authService.register(request);
    final data = AuthResponse.fromJson(res.data);

    await _saveTokens(data);
    return data;
  }

  @override
  Future<AuthResponse> verifyOtp(OtpVerifyRequest request) async {
    final Response res = await authService.verifyOtp(request);
    final data = AuthResponse.fromJson(res.data);

    await _saveTokens(data);
    return data;
  }

  @override
  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    final Response res = await authService.forgotPassword(request);
    return AuthResponse.fromJson(res.data);
  }

  @override
  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    final Response res = await authService.resetPassword(request);
    return AuthResponse.fromJson(res.data);
  }

  @override
  Future<void> resendOtp(String email) async {
    await authService.resendOtp(email);
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearAll(); //  FIXED (your real method)
  }

//
//   // =========================
//   // TOKEN SAVING (FIXED)
//   // =========================
//   Future<void> _saveTokens(AuthResponse response) async {
//     final accessToken = response.accessToken;
//     final refreshToken = response.refreshToken;
//
//     if (accessToken == null || refreshToken == null) {
//       return;
//     }
//
//     await tokenStorage.writeToken(accessToken);
//     await tokenStorage.writeRefreshToken(refreshToken);
//   }
// }

// =========================
// TOKEN SAVING
// =========================
  Future<void> _saveTokens(AuthResponse response) async {
    try {
      print("========== SAVING AUTH DATA ==========");

      print("User ID: ${response.userId}");
      print("Access Token: ${response.accessToken != null}");
      print("Refresh Token: ${response.refreshToken != null}");


      // Save Access Token
      if (response.accessToken != null &&
          response.accessToken!.isNotEmpty) {
        await tokenStorage.writeToken(
          response.accessToken!,
        );

        print("✅ Access token saved");
      } else {
        print("⚠️ Access token is null");
      }


      // Save Refresh Token
      if (response.refreshToken != null &&
          response.refreshToken!.isNotEmpty) {
        await tokenStorage.writeRefreshToken(
          response.refreshToken!,
        );

        print(" Refresh token saved");
      } else {
        print("s️ Refresh token is null");
      }


      // Save User ID
      if (response.userId != null) {
        await tokenStorage.writeUserId(
          response.userId!,
        );

        print(" User ID saved: ${response.userId}");
      } else {
        print("️ User ID is null");
      }


      // Verify
      final savedId = await tokenStorage.readUserId();

      print("========== VERIFY STORAGE ==========");
      print("Stored User ID: $savedId");
      print("====================================");
    } catch (e) {
      print(" SAVE AUTH DATA ERROR: $e");
      rethrow;
    }
  }
}